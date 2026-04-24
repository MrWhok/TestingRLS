## STEP1: ENABLE RLS
```sql
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
```

## STEP 2: 12.2 — SUPERADMIN POLICIES (Global View)

```sql
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
```

## STEP 3: 12.3 — TENANT POLICIES

```sql
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
```

## STEP 4: 12.4 — SUBTENANT POLICIES

```sql
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
```

## STEP 5: 12.5 — DONOR POLICIES

```sql
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
```