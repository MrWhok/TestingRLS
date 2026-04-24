// new
package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"net/http/cookiejar"
	"os"
	"strings"
	"time"

	"github.com/joho/godotenv"
)

type GuestTokenRequest struct {
	DashboardID string `json:"dashboardId"`
}

func getAccessToken(baseURL string, jar *cookiejar.Jar) (string, error) {
	username := os.Getenv("SUPERSET_USERNAME")
	password := os.Getenv("SUPERSET_PASSWORD")
	if username == "" || password == "" {
		return "", errors.New("SUPERSET_USERNAME and SUPERSET_PASSWORD must be set")
	}
	payload := map[string]interface{}{
		"username": username, "password": password,
		"provider": "db", "refresh": true,
	}
	body, _ := json.Marshal(payload)
	req, _ := http.NewRequest("POST", baseURL+"/api/v1/security/login", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	client := &http.Client{Jar: jar, Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	token, ok := result["access_token"].(string)
	if !ok {
		return "", errors.New("failed to get access_token")
	}
	return token, nil
}

func getCSRFToken(baseURL, accessToken string, jar *cookiejar.Jar) (string, error) {
	req, _ := http.NewRequest("GET", baseURL+"/api/v1/security/csrf_token/", nil)
	req.Header.Set("Authorization", "Bearer "+accessToken)
	client := &http.Client{Jar: jar, Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	csrf, ok := result["result"].(string)
	if !ok {
		return "", errors.New("failed to get csrf token")
	}
	return csrf, nil
}

func guestTokenHandler(w http.ResponseWriter, r *http.Request) {
	_ = godotenv.Overload()

	frontendURL := os.Getenv("FRONTEND_URL")
	if frontendURL == "" {
		frontendURL = "*"
	}
	w.Header().Set("Access-Control-Allow-Origin", frontendURL)
	w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// ==========================
	// HARDCODED TEST CONTEXT
	// ==========================
	// roleType := os.Getenv("TEST_ROLE")
	// fossilTenant := os.Getenv("TEST_TENANT")
	// fossilSubtenant := os.Getenv("TEST_SUBTENANT")
	// fossilDonor := os.Getenv("TEST_DONOR")

	roleType := "subtenant"     // "superadmin" | "tenant" | "subtenant" | "donor"
	fossilTenant := "KAJ"       // "KAJ"
	fossilSubtenant := "BEKASI" // "BEKASIUTARA"
	fossilDonor := ""           // "AGNES007"

	// Build structured username
	parts := []string{"role:" + roleType}
	if fossilTenant != "" {
		parts = append(parts, "tenant:"+fossilTenant)
	}
	if fossilSubtenant != "" {
		parts = append(parts, "subtenant:"+fossilSubtenant)
	}
	if fossilDonor != "" {
		parts = append(parts, "donor:"+fossilDonor)
	}
	structuredUsername := strings.Join(parts, ":")

	log.Printf("FOSSIL Guest Token: username=%s", structuredUsername)

	// ==========================
	// PARSE BODY
	// ==========================
	var reqBody GuestTokenRequest
	if err := json.NewDecoder(r.Body).Decode(&reqBody); err != nil {
		http.Error(w, "invalid body", http.StatusBadRequest)
		return
	}
	if reqBody.DashboardID == "" {
		http.Error(w, "dashboardId required", http.StatusBadRequest)
		return
	}

	supersetBase := os.Getenv("SUPERSET_BASE_URL")
	if supersetBase == "" {
		http.Error(w, "SUPERSET_BASE_URL not set", http.StatusInternalServerError)
		return
	}

	// ==========================
	// CALL SUPERSET
	// ==========================
	jar, _ := cookiejar.New(nil)

	accessToken, err := getAccessToken(supersetBase, jar)
	if err != nil {
		log.Println("Superset login failed:", err)
		http.Error(w, "login failed", http.StatusInternalServerError)
		return
	}

	csrfToken, err := getCSRFToken(supersetBase, accessToken, jar)
	if err != nil {
		log.Println("CSRF failed:", err)
		http.Error(w, "csrf failed", http.StatusInternalServerError)
		return
	}

	guestPayload := map[string]interface{}{
		"resources": []map[string]interface{}{
			{"type": "dashboard", "id": reqBody.DashboardID},
		},
		"rls": []map[string]interface{}{},
		"user": map[string]interface{}{
			"username":   structuredUsername,
			"first_name": "FOSSIL",
			"last_name":  fossilTenant,
		},
	}

	guestPayloadBytes, _ := json.Marshal(guestPayload)
	supReq, _ := http.NewRequest("POST", supersetBase+"/api/v1/security/guest_token/",
		bytes.NewBuffer(guestPayloadBytes))
	supReq.Header.Set("Authorization", "Bearer "+accessToken)
	supReq.Header.Set("X-CSRFToken", csrfToken)
	supReq.Header.Set("Content-Type", "application/json")

	client := &http.Client{Jar: jar, Timeout: 10 * time.Second}
	resp, err := client.Do(supReq)
	if err != nil {
		log.Println("guest_token request failed:", err)
		http.Error(w, "superset error", http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	if resp.StatusCode >= 300 {
		log.Printf("Superset error %d: %s", resp.StatusCode, string(body))
		http.Error(w, string(body), http.StatusBadGateway)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(body)
}

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}
	http.HandleFunc("/superset/guest-token", guestTokenHandler)
	log.Println("FOSSIL Superset bridge running on :" + port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
