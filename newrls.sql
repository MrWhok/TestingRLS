-- ============================================================
-- FOSSIL RLS MIGRATION — COMPLETE & CORRECTED
-- For debug/test database. Run as the schema owner (devpadang).
-- ============================================================

-- ============================================================
-- STEP 0: CREATE THE FOSSIL_READONLY ROLE FOR SUPERSET
-- Superset connects as this user. It has NO BYPASSRLS.
-- Run once. Skip if already exists.
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'fossil_readonly') THEN
    CREATE ROLE fossil_readonly LOGIN NOINHERIT PASSWORD 'change_me_in_prod';
  END IF;
END$$;

-- Grant connect + schema usage
GRANT CONNECT ON DATABASE postgres TO fossil_readonly;
GRANT USAGE ON SCHEMA public TO fossil_readonly;

-- Grant SELECT on all RLS-protected tables
GRANT SELECT ON
  public.tenant,
  public.subtenant,
  public.donor,
  public.donorcommitment,
  public.donorinvolvement,
  public.foster,
  public.fosterinvolvement,
  public.donorfosterpair,
  public."user",
  public.userlogin,
  public.halosiswalog,
  public.halosiswadata,
  public.dcaiyo,
  public.logrequestout,
  public.transferin,
  public.transferout,
  public.tenantbankaccountbalance,
  public.fostercostplan,
  public.fostercostplanline,
  public.fostercostplanlinedetail,
  public.programtariff
TO fossil_readonly;


-- ============================================================
-- STEP 1: DROP ALL EXISTING POLICIES (CLEAN SLATE)
-- ============================================================

-- §12.2 Platform Owner (old name: platform_owner)
DROP POLICY IF EXISTS owner_global_tenant_view ON public.tenant;
DROP POLICY IF EXISTS owner_global_subtenant_view ON public.subtenant;
DROP POLICY IF EXISTS owner_global_donor_view ON public.donor;
DROP POLICY IF EXISTS owner_global_donorcommitment_view ON public.donorcommitment;
DROP POLICY IF EXISTS owner_global_donorinvolvement_view ON public.donorinvolvement;
DROP POLICY IF EXISTS owner_global_foster_view ON public.foster;
DROP POLICY IF EXISTS owner_global_fosterinvolvement_view ON public.fosterinvolvement;
DROP POLICY IF EXISTS owner_global_donorfosterpair_view ON public.donorfosterpair;
DROP POLICY IF EXISTS owner_global_user_view ON public."user";
DROP POLICY IF EXISTS owner_global_userlogin_view ON public.userlogin;
DROP POLICY IF EXISTS owner_global_halosiswalog_view ON public.halosiswalog;
DROP POLICY IF EXISTS owner_global_halosiswadata_view ON public.halosiswadata;
DROP POLICY IF EXISTS owner_global_dcaiyo_view ON public.dcaiyo;
DROP POLICY IF EXISTS owner_global_logrequestout_view ON public.logrequestout;
DROP POLICY IF EXISTS owner_global_transferin_view ON public.transferin;
DROP POLICY IF EXISTS owner_global_transferout_view ON public.transferout;
DROP POLICY IF EXISTS owner_global_tenantbankaccountbalance_view ON public.tenantbankaccountbalance;
DROP POLICY IF EXISTS owner_global_fostercostplan_view ON public.fostercostplan;
DROP POLICY IF EXISTS owner_global_fostercostplanline_view ON public.fostercostplanline;
DROP POLICY IF EXISTS owner_global_fostercostplanlinedetail_view ON public.fostercostplanlinedetail;
DROP POLICY IF EXISTS owner_global_programtariff_view ON public.programtariff;

-- §12.3 Tenant
DROP POLICY IF EXISTS tenant_self_view ON public.tenant;
DROP POLICY IF EXISTS tenant_subtenant_view ON public.subtenant;
DROP POLICY IF EXISTS tenant_donor_view ON public.donor;
DROP POLICY IF EXISTS tenant_foster_view ON public.foster;
DROP POLICY IF EXISTS tenant_isolation_donorinvolvement ON public.donorinvolvement;
DROP POLICY IF EXISTS tenant_isolation_fosterinvolvement ON public.fosterinvolvement;
DROP POLICY IF EXISTS tenant_isolation_donorfosterpair ON public.donorfosterpair;
DROP POLICY IF EXISTS tenant_isolation_donorcommitment ON public.donorcommitment;
DROP POLICY IF EXISTS tenant_isolation_transferin ON public.transferin;
DROP POLICY IF EXISTS tenant_isolation_transferout ON public.transferout;
DROP POLICY IF EXISTS tenant_isolation_tenantbankaccountbalance ON public.tenantbankaccountbalance;
DROP POLICY IF EXISTS tenant_isolation_fostercostplan ON public.fostercostplan;
DROP POLICY IF EXISTS tenant_isolation_programtariff ON public.programtariff;
DROP POLICY IF EXISTS tenant_isolation_fcp_line ON public.fostercostplanline;
DROP POLICY IF EXISTS tenant_isolation_fcp_detail ON public.fostercostplanlinedetail;

-- §12.4 Subtenant
DROP POLICY IF EXISTS subtenant_tenant_view ON public.tenant;
DROP POLICY IF EXISTS subtenant_self_view ON public.subtenant;
DROP POLICY IF EXISTS subtenant_donor_view ON public.donor;
DROP POLICY IF EXISTS subtenant_foster_view ON public.foster;
DROP POLICY IF EXISTS subtenant_strict_donorinvolvement ON public.donorinvolvement;
DROP POLICY IF EXISTS subtenant_strict_fosterinvolvement ON public.fosterinvolvement;
DROP POLICY IF EXISTS subtenant_strict_donorfosterpair ON public.donorfosterpair;
DROP POLICY IF EXISTS subtenant_strict_donorcommitment ON public.donorcommitment;
DROP POLICY IF EXISTS subtenant_strict_transferin ON public.transferin;
DROP POLICY IF EXISTS subtenant_strict_transferout ON public.transferout;
DROP POLICY IF EXISTS subtenant_strict_fostercostplan ON public.fostercostplan;
DROP POLICY IF EXISTS subtenant_strict_programtariff ON public.programtariff;
DROP POLICY IF EXISTS subtenant_strict_fcp_line ON public.fostercostplanline;
DROP POLICY IF EXISTS subtenant_strict_fcp_detail ON public.fostercostplanlinedetail;

-- §12.5 Donor
DROP POLICY IF EXISTS donor_personal_donor ON public.donor;
DROP POLICY IF EXISTS donor_personal_transferin ON public.transferin;
DROP POLICY IF EXISTS donor_personal_donorcommitment ON public.donorcommitment;
DROP POLICY IF EXISTS donor_personal_donorfosterpair ON public.donorfosterpair;
DROP POLICY IF EXISTS donor_personal_foster ON public.foster;


-- ============================================================
-- STEP 2: ENABLE RLS + FORCE RLS ON ALL TABLES
-- FORCE RLS ensures even the table owner (devpadang) obeys policies.
-- Without FORCE, devpadang bypasses all policies silently.
-- ============================================================

ALTER TABLE public.tenant                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subtenant               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donor                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donorcommitment         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donorinvolvement        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foster                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fosterinvolvement       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donorfosterpair         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."user"                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.userlogin               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.halosiswalog            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.halosiswadata           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dcaiyo                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.logrequestout           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transferin              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transferout             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenantbankaccountbalance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fostercostplan          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fostercostplanline      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fostercostplanlinedetail ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.programtariff           ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.tenant                  FORCE ROW LEVEL SECURITY;
ALTER TABLE public.subtenant               FORCE ROW LEVEL SECURITY;
ALTER TABLE public.donor                   FORCE ROW LEVEL SECURITY;
ALTER TABLE public.donorcommitment         FORCE ROW LEVEL SECURITY;
ALTER TABLE public.donorinvolvement        FORCE ROW LEVEL SECURITY;
ALTER TABLE public.foster                  FORCE ROW LEVEL SECURITY;
ALTER TABLE public.fosterinvolvement       FORCE ROW LEVEL SECURITY;
ALTER TABLE public.donorfosterpair         FORCE ROW LEVEL SECURITY;
ALTER TABLE public."user"                  FORCE ROW LEVEL SECURITY;
ALTER TABLE public.userlogin               FORCE ROW LEVEL SECURITY;
ALTER TABLE public.halosiswalog            FORCE ROW LEVEL SECURITY;
ALTER TABLE public.halosiswadata           FORCE ROW LEVEL SECURITY;
ALTER TABLE public.dcaiyo                  FORCE ROW LEVEL SECURITY;
ALTER TABLE public.logrequestout           FORCE ROW LEVEL SECURITY;
ALTER TABLE public.transferin              FORCE ROW LEVEL SECURITY;
ALTER TABLE public.transferout             FORCE ROW LEVEL SECURITY;
ALTER TABLE public.tenantbankaccountbalance FORCE ROW LEVEL SECURITY;
ALTER TABLE public.fostercostplan          FORCE ROW LEVEL SECURITY;
ALTER TABLE public.fostercostplanline      FORCE ROW LEVEL SECURITY;
ALTER TABLE public.fostercostplanlinedetail FORCE ROW LEVEL SECURITY;
ALTER TABLE public.programtariff           FORCE ROW LEVEL SECURITY;


-- ============================================================
-- STEP 3: §12.2 — SUPERADMIN POLICIES (Global View)
-- FIX: renamed 'platform_owner' → 'superadmin' to match FOSSIL codebase.
-- Superadmin sees ALL rows, no tenant filter.
-- logrequestout & halosiswadata have NO tenant column — superadmin only.
-- ============================================================

-- Tables with tenant column: superadmin sees all rows
CREATE POLICY superadmin_tenant         ON public.tenant                   FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_subtenant      ON public.subtenant                FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_donor          ON public.donor                    FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_donorcommitment ON public.donorcommitment         FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_donorinvolvement ON public.donorinvolvement       FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_foster         ON public.foster                   FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_fosterinvolvement ON public.fosterinvolvement     FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_donorfosterpair ON public.donorfosterpair         FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_user           ON public."user"                   FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_userlogin      ON public.userlogin                FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_halosiswalog   ON public.halosiswalog             FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_dcaiyo         ON public.dcaiyo                   FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_transferin     ON public.transferin               FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_transferout    ON public.transferout              FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_tenantbankaccountbalance ON public.tenantbankaccountbalance FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_fostercostplan ON public.fostercostplan           FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_fostercostplanline ON public.fostercostplanline   FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_fostercostplanlinedetail ON public.fostercostplanlinedetail FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_programtariff  ON public.programtariff            FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');

CREATE POLICY superadmin_logrequestout  ON public.logrequestout            FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');
CREATE POLICY superadmin_halosiswadata  ON public.halosiswadata            FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'superadmin');


-- ============================================================
-- STEP 4: §12.3 — TENANT POLICIES
-- Tenant users see all data within their tenant, across all subtenants.
-- ============================================================

CREATE POLICY tenant_tenant             ON public.tenant                   FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_subtenant          ON public.subtenant                FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_donor              ON public.donor                    FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_foster             ON public.foster                   FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_donorinvolvement   ON public.donorinvolvement         FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_fosterinvolvement  ON public.fosterinvolvement        FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_donorfosterpair    ON public.donorfosterpair          FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_donorcommitment    ON public.donorcommitment          FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_transferin         ON public.transferin               FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_transferout        ON public.transferout              FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_tenantbankaccountbalance ON public.tenantbankaccountbalance FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_fostercostplan     ON public.fostercostplan           FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_programtariff      ON public.programtariff            FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_dcaiyo             ON public.dcaiyo                   FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_halosiswalog       ON public.halosiswalog             FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY tenant_userlogin          ON public.userlogin                FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'tenant' AND tenant = current_setting('app.current_tenant', TRUE));

CREATE POLICY tenant_fostercostplanline ON public.fostercostplanline FOR SELECT TO public USING (
    current_setting('app.current_role', TRUE) = 'tenant'
    AND EXISTS (
        SELECT 1 FROM public.fostercostplan fcp
        WHERE fcp.fostercostplanid = fostercostplanline.fostercostplanid
          AND fcp.tenant = current_setting('app.current_tenant', TRUE)
    )
);

CREATE POLICY tenant_fostercostplanlinedetail ON public.fostercostplanlinedetail FOR SELECT TO public USING (
    current_setting('app.current_role', TRUE) = 'tenant'
    AND EXISTS (
        SELECT 1 FROM public.fostercostplanline fcpl
        JOIN public.fostercostplan fcp ON fcp.fostercostplanid = fcpl.fostercostplanid
        WHERE fcpl.fostercostplanlineid = fostercostplanlinedetail.fostercostplanlineid
          AND fcp.tenant = current_setting('app.current_tenant', TRUE)
    )
);


-- ============================================================
-- STEP 5: §12.4 — SUBTENANT POLICIES
-- Subtenant users see only their own subtenant's data.
-- donor and foster: scoped to tenant only (subtenant users can see all donors/fosters
-- within their tenant, but involvement/pair/commitment is subtenant-scoped).
-- ============================================================

CREATE POLICY subtenant_tenant          ON public.tenant                   FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY subtenant_subtenant       ON public.subtenant                FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE));
CREATE POLICY subtenant_donor           ON public.donor                    FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY subtenant_foster          ON public.foster                   FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY subtenant_donorinvolvement ON public.donorinvolvement        FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE));
CREATE POLICY subtenant_fosterinvolvement ON public.fosterinvolvement      FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE));
CREATE POLICY subtenant_donorfosterpair ON public.donorfosterpair          FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE));
CREATE POLICY subtenant_donorcommitment ON public.donorcommitment          FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE));
CREATE POLICY subtenant_transferin      ON public.transferin               FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE));
CREATE POLICY subtenant_transferout     ON public.transferout              FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE));
CREATE POLICY subtenant_fostercostplan  ON public.fostercostplan           FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE));
CREATE POLICY subtenant_programtariff   ON public.programtariff            FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE));
CREATE POLICY subtenant_dcaiyo          ON public.dcaiyo                   FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE));
CREATE POLICY subtenant_halosiswalog    ON public.halosiswalog             FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE));
CREATE POLICY subtenant_userlogin       ON public.userlogin                FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'subtenant' AND tenant = current_setting('app.current_tenant', TRUE) AND subtenant = current_setting('app.current_subtenant', TRUE));

CREATE POLICY subtenant_fostercostplanline ON public.fostercostplanline FOR SELECT TO public USING (
    current_setting('app.current_role', TRUE) = 'subtenant'
    AND EXISTS (
        SELECT 1 FROM public.fostercostplan fcp
        WHERE fcp.fostercostplanid = fostercostplanline.fostercostplanid
          AND fcp.tenant = current_setting('app.current_tenant', TRUE)
          AND fcp.subtenant = current_setting('app.current_subtenant', TRUE)
    )
);

CREATE POLICY subtenant_fostercostplanlinedetail ON public.fostercostplanlinedetail FOR SELECT TO public USING (
    current_setting('app.current_role', TRUE) = 'subtenant'
    AND EXISTS (
        SELECT 1 FROM public.fostercostplanline fcpl
        JOIN public.fostercostplan fcp ON fcp.fostercostplanid = fcpl.fostercostplanid
        WHERE fcpl.fostercostplanlineid = fostercostplanlinedetail.fostercostplanlineid
          AND fcp.tenant = current_setting('app.current_tenant', TRUE)
          AND fcp.subtenant = current_setting('app.current_subtenant', TRUE)
    )
);


-- ============================================================
-- STEP 6: §12.5 — DONOR POLICIES
-- Donors see only their own data.
-- foster: via EXISTS join through donorfosterpair (donor has no direct foster link).
-- ============================================================

CREATE POLICY donor_donor               ON public.donor                    FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'donor' AND tenant = current_setting('app.current_tenant', TRUE) AND donor = current_setting('app.current_donor', TRUE));
CREATE POLICY donor_donorcommitment     ON public.donorcommitment          FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'donor' AND tenant = current_setting('app.current_tenant', TRUE) AND donor = current_setting('app.current_donor', TRUE));
CREATE POLICY donor_donorfosterpair     ON public.donorfosterpair          FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'donor' AND tenant = current_setting('app.current_tenant', TRUE) AND donor = current_setting('app.current_donor', TRUE));
CREATE POLICY donor_donorinvolvement    ON public.donorinvolvement         FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'donor' AND tenant = current_setting('app.current_tenant', TRUE) AND donor = current_setting('app.current_donor', TRUE));
CREATE POLICY donor_transferin          ON public.transferin               FOR SELECT TO public USING (current_setting('app.current_role', TRUE) = 'donor' AND tenant = current_setting('app.current_tenant', TRUE) AND donor = current_setting('app.current_donor', TRUE));

CREATE POLICY donor_foster              ON public.foster                   FOR SELECT TO public USING (
    current_setting('app.current_role', TRUE) = 'donor'
    AND EXISTS (
        SELECT 1 FROM public.donorfosterpair dfp
        WHERE dfp.tenant = foster.tenant
          AND dfp.foster = foster.foster
          AND dfp.donor = current_setting('app.current_donor', TRUE)
    )
);


-- ============================================================
-- STEP 7: VERIFY — List all policies created
-- ============================================================
SELECT
    schemaname,
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;