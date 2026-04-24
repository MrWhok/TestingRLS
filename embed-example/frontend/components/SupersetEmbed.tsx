//new
import { useEffect, useRef, useState } from "react";
import { embedDashboard } from "@superset-ui/embedded-sdk";

const DASHBOARD_ID   = process.env.NEXT_PUBLIC_DEMO_DASHBOARD_ID || "";
const FILTER_ID      = process.env.NEXT_PUBLIC_FILTER_ID || "";
const SUPERSET_DOMAIN = process.env.NEXT_PUBLIC_SUPERSET_DOMAIN || "";
const GUEST_TOKEN_URL = process.env.NEXT_PUBLIC_GUEST_TOKEN_URL || "";

export default function SupersetEmbed() {
  const ref          = useRef<HTMLDivElement>(null);
  const dashboardRef = useRef<any>(null);
  const [activeOnly, setActiveOnly] = useState(true);

  // ==============================
  // APPLY NATIVE FILTER
  // ==============================
  const applyFilter = (embed: any, isActive: boolean) => {
    const statusValue = isActive ? ["ACTIVE"] : ["INACTIVE"];

    embed?.postMessage?.(
      {
        type: "setDataMask",
        payload: {
          dataMask: {
            [FILTER_ID]: {
              filterState: {
                value: statusValue,
                label: statusValue.join(", "),
              },
              extraFormData: {
                filters: [{ col: "status", op: "IN", val: statusValue }],
              },
              ownState: {},
            },
          },
        },
      },
      SUPERSET_DOMAIN
    );

    setTimeout(() => {
      embed?.postMessage?.({ type: "applyFilters" }, SUPERSET_DOMAIN);
    }, 200);
  };

  useEffect(() => {
    let resizeHandler: () => void = () => {};

    const load = async () => {

      // ==============================
      // FETCH GUEST TOKEN
      // No JWT — context is provided by the bridge via .env (TEST_ROLE etc.)
      // To switch roles, change TEST_ROLE / TEST_TENANT / TEST_SUBTENANT in
      // backend/.env and restart main.go. No frontend changes needed.
      // ==============================
      const fetchGuestToken = async (): Promise<string> => {
        const res = await fetch(GUEST_TOKEN_URL, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ dashboardId: DASHBOARD_ID }),
        });

        if (!res.ok) {
          const errText = await res.text();
          throw new Error(`Guest token failed (${res.status}): ${errText}`);
        }

        const data = await res.json();
        return data.token;
      };

      // ==============================
      // EMBED DASHBOARD
      // ==============================
      const embed = await embedDashboard({
        id: DASHBOARD_ID,
        supersetDomain: SUPERSET_DOMAIN,
        mountPoint: ref.current!,
        fetchGuestToken,
      });

      dashboardRef.current = embed;

      // Apply default filter after embed loads
      setTimeout(() => applyFilter(embed, true), 600);

      // Style the iframe
      const styleIframe = () => {
        if (!ref.current) return;
        const iframe = ref.current.querySelector("iframe");
        if (!iframe) return;
        const el = iframe as HTMLIFrameElement;
        el.style.width     = "100%";
        el.style.height    = "80vh";
        el.style.minHeight = "600px";
        el.style.border    = "0";
      };

      [200, 600, 1200].forEach((d) => setTimeout(styleIframe, d));
      resizeHandler = styleIframe;
      window.addEventListener("resize", resizeHandler);
    };

    load();

    return () => {
      window.removeEventListener("resize", resizeHandler);
    };
  }, []);

  const toggleActive = () => {
    const next = !activeOnly;
    setActiveOnly(next);
    if (dashboardRef.current) applyFilter(dashboardRef.current, next);
  };

  return (
    <div>
      <button
        onClick={toggleActive}
        style={{
          marginBottom: 12,
          padding: "8px 16px",
          background: activeOnly ? "#1FA8C9" : "#888",
          color: "white",
          border: "none",
          borderRadius: 6,
          cursor: "pointer",
        }}
      >
        {activeOnly ? "ACTIVE" : "INACTIVE"}
      </button>
      <div ref={ref} style={{ width: "100%", height: "80vh" }} />
    </div>
  );
}