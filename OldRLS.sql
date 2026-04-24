1. Enable Row Level Security (RLS) on All Required Tables

```sql
ALTER TABLE public.tenant ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subtenant ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donor ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donorcommitment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donorinvolvement ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foster ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fosterinvolvement ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donorfosterpair ENABLE ROW LEVEL SECURITY;

ALTER TABLE public."user" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.userlogin ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.halosiswalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.halosiswadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dcaiyo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.logrequestout ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.transferin ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transferout ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenantbankaccountbalance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fostercostplan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fostercostplanline ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fostercostplanlinedetail ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.programtariff ENABLE ROW LEVEL SECURITY;
```

2. RLS 12.2 Implementation: Platform Owner Policies (Global View)

```sql
CREATE POLICY owner_global_tenant_view ON public.tenant FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_subtenant_view ON public.subtenant FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_donor_view ON public.donor FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_donorcommitment_view ON public.donorcommitment FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_donorinvolvement_view ON public.donorinvolvement FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_foster_view ON public.foster FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_fosterinvolvement_view ON public.fosterinvolvement FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_donorfosterpair_view ON public.donorfosterpair FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');

CREATE POLICY owner_global_user_view ON public."user" FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_userlogin_view ON public.userlogin FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_halosiswalog_view ON public.halosiswalog FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_halosiswadata_view ON public.halosiswadata FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_dcaiyo_view ON public.dcaiyo FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
CREATE POLICY owner_global_logrequestout_view ON public.logrequestout FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'platform_owner');
```

3. RLS 12.3: TENANT POLICIES (Tenant Boundary Isolation)

```sql
CREATE POLICY tenant_self_view ON public.tenant FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_subtenant_view ON public.subtenant FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_donor_view ON public.donor FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_foster_view ON public.foster FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');

CREATE POLICY tenant_isolation_donorinvolvement ON public.donorinvolvement FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_isolation_fosterinvolvement ON public.fosterinvolvement FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_isolation_donorfosterpair ON public.donorfosterpair FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_isolation_donorcommitment ON public.donorcommitment FOR ALL TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_isolation_transferin ON public.transferin FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_isolation_transferout ON public.transferout FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_isolation_tenantbankaccountbalance ON public.tenantbankaccountbalance FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_isolation_fostercostplan ON public.fostercostplan FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_isolation_programtariff ON public.programtariff FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'tenant');

CREATE POLICY tenant_isolation_fcp_line ON public.fostercostplanline FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant');
CREATE POLICY tenant_isolation_fcp_detail ON public.fostercostplanlinedetail FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant');
```

4. RLS 12.4: SUB-TENANT POLICIES (Strict Branch Isolation)

```sql
CREATE POLICY subtenant_tenant_view ON public.tenant FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');
CREATE POLICY subtenant_self_view ON public.subtenant FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');
CREATE POLICY subtenant_donor_view ON public.donor FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');
CREATE POLICY subtenant_foster_view ON public.foster FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');

CREATE POLICY subtenant_strict_donorinvolvement ON public.donorinvolvement FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');
CREATE POLICY subtenant_strict_fosterinvolvement ON public.fosterinvolvement FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');
CREATE POLICY subtenant_strict_donorfosterpair ON public.donorfosterpair FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');
CREATE POLICY subtenant_strict_donorcommitment ON public.donorcommitment FOR ALL TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');
CREATE POLICY subtenant_strict_transferin ON public.transferin FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');
CREATE POLICY subtenant_strict_transferout ON public.transferout FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');
CREATE POLICY subtenant_strict_fostercostplan ON public.fostercostplan FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');
CREATE POLICY subtenant_strict_programtariff ON public.programtariff FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE) AND current_setting('app.current_role', TRUE) = 'subtenant');

CREATE POLICY subtenant_strict_fcp_line ON public.fostercostplanline FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant');
CREATE POLICY subtenant_strict_fcp_detail ON public.fostercostplanlinedetail FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant');
```

5. RLS 12.5 Implementation: Donor Policies (Personal Impact)

```sql
CREATE POLICY donor_personal_donor ON public.donor FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND donor = current_setting('app.current_donor', TRUE) AND current_setting('app.current_role', TRUE) = 'donor');
CREATE POLICY donor_personal_transferin ON public.transferin FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND donor = current_setting('app.current_donor', TRUE) AND current_setting('app.current_role', TRUE) = 'donor');
CREATE POLICY donor_personal_donorcommitment ON public.donorcommitment FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND donor = current_setting('app.current_donor', TRUE) AND current_setting('app.current_role', TRUE) = 'donor');

CREATE POLICY donor_personal_donorfosterpair ON public.donorfosterpair FOR SELECT TO public USING (tenant = current_setting('app.current_tenant', TRUE) AND donor = current_setting('app.current_donor', TRUE) AND current_setting('app.current_role', TRUE) = 'donor');

CREATE POLICY donor_personal_foster ON public.foster FOR SELECT TO public USING (
    current_setting('app.current_role', TRUE) = 'donor'
    AND EXISTS (
        SELECT 1 FROM public.donorfosterpair dfp 
        WHERE dfp.tenant = foster.tenant AND dfp.foster = foster.foster AND dfp.donor = current_setting('app.current_donor', TRUE)
    )
);
```

6. 12.2 Testing

**Ambil kode dari issue github 12.2 lalu copy kedalam template dibawah ini:**
```sql
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('app.current_role', 'platform_owner', true);

----COPY KODE SQL DISINI----

ROLLBACK;
```
**Ubah `platform_owner` jika ingin mengetest apakah bisa diakses selain platform_owner. Contoh:**

- 12.2.1 Overview Dashboard Platform Owner

```sql
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('app.current_role', 'platform_owner', true);

SELECT
  (SELECT COUNT(*) FROM tenant) AS total_tenants,
  (SELECT COUNT(*) FROM subtenant) AS total_subtenants,
  (SELECT COUNT(*) FROM donor) AS total_donors;

ROLLBACK;
```
```sql
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('app.current_role', 'platform_owner', true);

SELECT
  (SELECT COUNT(*) FROM "user") AS total_users,
  (SELECT COUNT(*) FROM userlogin) AS total_login_events,
  (SELECT COUNT(DISTINCT "user") FROM userlogin) AS unique_logged_in_users;

ROLLBACK;
```
```sql
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('app.current_role', 'platform_owner', true);

SELECT
  (SELECT COUNT(*) FROM tenant) AS total_tenants,
  (SELECT COUNT(*) FROM subtenant) AS total_subtenants,
  (SELECT COUNT(*) FROM donor) AS total_donors;

ROLLBACK;
```
```sql
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('app.current_role', 'platform_owner', true);

SELECT
  (SELECT COUNT(*) FROM halosiswalog) AS total_halosis_log,
  (SELECT COUNT(*) FROM halosiswadata) AS total_halosis_data,
  (SELECT COUNT(*) FROM dcaiyo) AS total_dcaiyo_rows;

ROLLBACK;
```


7. 12.3 Testing

**Ambil kode dari issue github 12.3 lalu copy kedalam template dibawah ini:**

```sql
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('app.current_role', 'tenant', true);
SELECT set_config('app.current_tenant', 'CURRENT_TENANT_CODE', true);

----COPY KODE SQL DISINI----

ROLLBACK;
```
**Ubah `CURRENT_TENANT_CODE` dengan kode tenant untuk pengujian (misal: `ALSANTO`). Contoh:**

- 12.3.1 Total Active Fosters

```sql
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('app.current_role', 'tenant', true);
SELECT set_config('app.current_tenant', 'ALSANTO', true);

SELECT COUNT(DISTINCT fi.foster) AS total_active_fosters
FROM fosterinvolvement fi
WHERE fi.tenant = 'ALSANTO'
  AND fi.status = 'ACTIVE'
  AND (fi.enddate IS NULL OR fi.enddate >= CURRENT_DATE);

ROLLBACK;
```

- 12.3.2 Total Active Commitments

```sql
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('app.current_role', 'tenant', true);
SELECT set_config('app.current_tenant', 'CURRENT_TENANT_CODE', true);

SELECT COUNT(*) AS total_active_commitments
FROM donorcommitment dc
WHERE dc.tenant = 'TENANT_CODE'
  AND dc.balance > 0;

ROLLBACK;
```

8. 12.4 Testing

**Ambil kode dari issue github 12.4 lalu copy kedalam template dibawah ini:**

```sql
BEGIN;
SET LOCAL ROLE authenticated;

SELECT set_config('app.current_role', 'subtenant', true);
SELECT set_config('app.current_tenant', 'CURRENT_TENANT_CODE', true);
SELECT set_config('app.current_subtenant', 'CURRENT_SUBTENANT_CODE', true); 

----COPY KODE SQL DISINI----

ROLLBACK;
```
**Ubah `CURRENT_TENANT_CODE` dengan kode tenant untuk pengujian (misal: `KAJ`) dan `CURRENT_SUBTENANT_CODE` dengan kode subtenant untuk pengujian (misal: `BEKASI`). Contoh:**

- 12.4.1 Sub-Tenant Total Active Foster

```sql
BEGIN;
SET LOCAL ROLE authenticated;

SELECT set_config('app.current_role', 'subtenant', true);
SELECT set_config('app.current_tenant', 'KAJ', true);
SELECT set_config('app.current_subtenant', 'BEKASI', true); 

SELECT 
  fi.subtenant,
  COUNT(DISTINCT f.foster) AS total_active_foster
FROM foster f
JOIN fosterinvolvement fi ON f.foster = fi.foster
WHERE f.status <> 'DELETED'
  AND fi.status = 'ACTIVE'
GROUP BY fi.subtenant
ORDER BY fi.subtenant ASC;

ROLLBACK;
```
- 12.4.2 Sub-Tenant Total Active Donor

```sql
BEGIN;
SET LOCAL ROLE authenticated;

SELECT set_config('app.current_role', 'subtenant', true);
SELECT set_config('app.current_tenant', 'KAJ', true);
SELECT set_config('app.current_subtenant', 'BEKASI', true); 

SELECT 
  di.subtenant,
  COUNT(DISTINCT d.donor) AS total_active_donor
FROM donor d
JOIN donorinvolvement di ON d.tenant = di.tenant AND d.donor = di.donor
WHERE d.status <> 'DELETED'
  AND d.status = 'ACTIVE'
GROUP BY di.subtenant
ORDER BY di.subtenant ASC;

ROLLBACK;
```

9. 12.5 Testing

**Ambil kode dari issue github 12.5 lalu copy kedalam template dibawah ini:**

```sql
BEGIN;
SET LOCAL ROLE authenticated;

-- Simulasi login sebagai Donor
SELECT set_config('app.current_role', 'donor', true);
SELECT set_config('app.current_tenant', 'CURRENT_TENANT_CODE', true);
SELECT set_config('app.current_donor', 'CURRENT_DONOR_CODE', true);

----COPY KODE SQL DISINI----

ROLLBACK;
```

**Ubah `CURRENT_TENANT_CODE` dengan kode tenant untuk pengujian (misal: `ALSANTO`), `CURRENT_DONOR_CODE` dengan kode donor untuk pengujian (misal: `AGNES007`). Contoh:**

```sql
BEGIN;
SET LOCAL ROLE authenticated;

-- Simulasi login sebagai Donor
SELECT set_config('app.current_role', 'donor', true);
SELECT set_config('app.current_tenant', 'ALSANTO', true);
SELECT set_config('app.current_donor', 'AGNES007', true);

WITH pair_base AS (
  SELECT
    dfp.tenant,
    dfp.subtenant,
    dfp.donor,
    dfp.foster,
    f.name AS foster_name,
    dfp.program,
    COALESCE(dfp.portion, 0) AS portion,
    TO_CHAR(dfp.startdate, 'YYYYMM') AS start_periode,
    TO_CHAR(dfp.enddate, 'YYYYMM') AS end_periode
  FROM donorfosterpair dfp
  JOIN foster f
    ON f.tenant = dfp.tenant
    AND f.foster = dfp.foster
  WHERE dfp.tenant = 'ALSANTO'
    AND dfp.subtenant = 'ALSANTO'
    AND dfp.donor = 'AGNES007'
    AND dfp.status = 'ACTIVE'
    AND f.status <> 'DELETED'
),
allocated AS (
  SELECT
    pb.tenant,
    pb.subtenant,
    pb.donor,
    pb.foster,
    pb.foster_name,
    pb.program,
    pb.portion,
    dc.periodecode,
    (COALESCE(dc.amount, 0) * pb.portion / 100.0) AS allocated_commitment,
    ((COALESCE(dc.amount, 0) - COALESCE(dc.balance, 0)) * pb.portion / 100.0) AS allocated_fulfilled,
    (COALESCE(dc.balance, 0) * pb.portion / 100.0) AS allocated_outstanding
  FROM pair_base pb
  LEFT JOIN donorcommitment dc
    ON dc.tenant = pb.tenant
    AND dc.subtenant = pb.subtenant
    AND dc.donor = pb.donor
    AND dc.program = pb.program
    AND dc.periodecode BETWEEN pb.start_periode AND pb.end_periode
)
SELECT
  a.tenant,
  a.subtenant,
  a.donor,
  a.foster,
  a.foster_name,
  a.program,
  ROUND(SUM(a.allocated_commitment)::numeric, 2) AS total_commitment_allocated,
  ROUND(SUM(a.allocated_fulfilled)::numeric, 2) AS total_fulfilled_allocated,
  ROUND(SUM(a.allocated_outstanding)::numeric, 2) AS total_outstanding_allocated,
  CASE
    WHEN SUM(a.allocated_commitment) = 0 THEN 0
    ELSE ROUND(
      (SUM(a.allocated_fulfilled) * 100.0 / SUM(a.allocated_commitment))::numeric, 2
    )
  END AS fulfillment_percent,
  CASE
    WHEN SUM(a.allocated_commitment) = 0 THEN 'NO COMMITMENT'
    WHEN SUM(a.allocated_fulfilled) >= SUM(a.allocated_commitment) THEN 'FULLY FULFILLED'
    WHEN SUM(a.allocated_fulfilled) > 0 THEN 'PARTIALLY FULFILLED'
    ELSE 'NOT FULFILLED'
  END AS commitment_fulfillment_status
FROM allocated a
GROUP BY
  a.tenant, a.subtenant, a.donor, a.foster, a.foster_name, a.program
ORDER BY a.foster_name, a.program;

ROLLBACK;
```

