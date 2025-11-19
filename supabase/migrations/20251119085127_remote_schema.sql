drop extension if exists "pg_net";

create sequence "public"."job_logs_id_seq";


  create table "public"."engines" (
    "id" uuid not null default gen_random_uuid(),
    "slug" text not null,
    "name" text not null,
    "description" text,
    "category" text,
    "status" text default 'offline'::text,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."job_logs" (
    "id" bigint not null default nextval('public.job_logs_id_seq'::regclass),
    "job_id" uuid,
    "level" text default 'info'::text,
    "message" text not null,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."jobs" (
    "id" uuid not null default gen_random_uuid(),
    "engine_slug" text not null,
    "payload" jsonb not null,
    "status" text not null default 'queued'::text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."kb_master_index" (
    "id" uuid not null default gen_random_uuid(),
    "version_label" text not null,
    "is_current" boolean not null default false,
    "content_md" text not null,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."kb_snapshots" (
    "id" uuid not null default gen_random_uuid(),
    "topic" text not null,
    "source_chat_hint" text,
    "capsule_version" text,
    "content_md" text not null,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."kb_snapshots_v2" (
    "id" uuid not null default gen_random_uuid(),
    "topic" text not null,
    "capsule_version" text,
    "source_chat_hint" text,
    "content_md" text not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."kb_snapshots_v2" enable row level security;


  create table "public"."kb_universes" (
    "id" uuid not null default gen_random_uuid(),
    "slug" text not null,
    "type" text not null,
    "display_name" text not null,
    "status" text not null default 'idea'::text,
    "notes" jsonb default '{}'::jsonb,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."waitlist_subscribers" (
    "id" uuid not null default gen_random_uuid(),
    "email" text not null,
    "note" text,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."zalara_audit" (
    "ts" timestamp with time zone not null default now(),
    "actor" uuid,
    "scope" text,
    "action" text,
    "ref" text,
    "ip" inet,
    "details" jsonb not null default '{}'::jsonb
      );


alter table "public"."zalara_audit" enable row level security;


  create table "public"."zalara_campaigns" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "name" text not null,
    "template_id" uuid,
    "schedule_json" jsonb not null default '{}'::jsonb,
    "status" text not null default 'inactive'::text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."zalara_campaigns" enable row level security;


  create table "public"."zalara_jobs" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "type" text not null,
    "priority" text not null default 'normal'::text,
    "status" text not null default 'pending'::text,
    "created_at" timestamp with time zone not null default now(),
    "started_at" timestamp with time zone,
    "finished_at" timestamp with time zone,
    "error" text,
    "payload_json" jsonb not null default '{}'::jsonb,
    "outputs_json" jsonb not null default '{}'::jsonb,
    "retries" integer not null default 0,
    "claim_token" text
      );


alter table "public"."zalara_jobs" enable row level security;


  create table "public"."zalara_quotas" (
    "user_id" uuid not null,
    "plan" text not null default 'free'::text,
    "parallel_cap" integer not null default 1,
    "max_minutes" integer not null default 60,
    "watermark_policy" text not null default 'required'::text,
    "feature_gates_json" jsonb not null default '{}'::jsonb,
    "reset_at" timestamp with time zone not null default (now() + '30 days'::interval)
      );


alter table "public"."zalara_quotas" enable row level security;


  create table "public"."zalara_templates" (
    "id" uuid not null default gen_random_uuid(),
    "owner_id" uuid not null,
    "kind" text not null,
    "payload_json" jsonb not null default '{}'::jsonb,
    "overlays_json" jsonb not null default '[]'::jsonb,
    "luts_json" jsonb not null default '[]'::jsonb,
    "storyboard_json" jsonb not null default '[]'::jsonb,
    "public" boolean not null default false,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."zalara_templates" enable row level security;


  create table "public"."zalara_webhooks" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "event" text not null,
    "url" text not null,
    "secret" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."zalara_webhooks" enable row level security;

alter sequence "public"."job_logs_id_seq" owned by "public"."job_logs"."id";

CREATE UNIQUE INDEX engines_pkey ON public.engines USING btree (id);

CREATE UNIQUE INDEX engines_slug_key ON public.engines USING btree (slug);

CREATE INDEX idx_job_logs_job_id ON public.job_logs USING btree (job_id);

CREATE INDEX idx_jobs_engine_status ON public.jobs USING btree (engine_slug, status);

CREATE INDEX idx_jobs_status_created ON public.zalara_jobs USING btree (status, created_at DESC);

CREATE INDEX idx_jobs_user_created ON public.zalara_jobs USING btree (user_id, created_at DESC);

CREATE INDEX idx_tmpl_owner_public ON public.zalara_templates USING btree (owner_id, public);

CREATE UNIQUE INDEX job_logs_pkey ON public.job_logs USING btree (id);

CREATE UNIQUE INDEX jobs_pkey ON public.jobs USING btree (id);

CREATE UNIQUE INDEX kb_master_index_one_current ON public.kb_master_index USING btree (is_current) WHERE (is_current = true);

CREATE UNIQUE INDEX kb_master_index_pkey ON public.kb_master_index USING btree (id);

CREATE UNIQUE INDEX kb_snapshots_pkey ON public.kb_snapshots USING btree (id);

CREATE UNIQUE INDEX kb_snapshots_v2_pkey ON public.kb_snapshots_v2 USING btree (id);

CREATE UNIQUE INDEX kb_universes_pkey ON public.kb_universes USING btree (id);

CREATE UNIQUE INDEX kb_universes_slug_key ON public.kb_universes USING btree (slug);

CREATE UNIQUE INDEX waitlist_subscribers_pkey ON public.waitlist_subscribers USING btree (id);

CREATE UNIQUE INDEX zalara_campaigns_pkey ON public.zalara_campaigns USING btree (id);

CREATE UNIQUE INDEX zalara_jobs_pkey ON public.zalara_jobs USING btree (id);

CREATE UNIQUE INDEX zalara_quotas_pkey ON public.zalara_quotas USING btree (user_id);

CREATE UNIQUE INDEX zalara_templates_pkey ON public.zalara_templates USING btree (id);

CREATE UNIQUE INDEX zalara_webhooks_pkey ON public.zalara_webhooks USING btree (id);

alter table "public"."engines" add constraint "engines_pkey" PRIMARY KEY using index "engines_pkey";

alter table "public"."job_logs" add constraint "job_logs_pkey" PRIMARY KEY using index "job_logs_pkey";

alter table "public"."jobs" add constraint "jobs_pkey" PRIMARY KEY using index "jobs_pkey";

alter table "public"."kb_master_index" add constraint "kb_master_index_pkey" PRIMARY KEY using index "kb_master_index_pkey";

alter table "public"."kb_snapshots" add constraint "kb_snapshots_pkey" PRIMARY KEY using index "kb_snapshots_pkey";

alter table "public"."kb_snapshots_v2" add constraint "kb_snapshots_v2_pkey" PRIMARY KEY using index "kb_snapshots_v2_pkey";

alter table "public"."kb_universes" add constraint "kb_universes_pkey" PRIMARY KEY using index "kb_universes_pkey";

alter table "public"."waitlist_subscribers" add constraint "waitlist_subscribers_pkey" PRIMARY KEY using index "waitlist_subscribers_pkey";

alter table "public"."zalara_campaigns" add constraint "zalara_campaigns_pkey" PRIMARY KEY using index "zalara_campaigns_pkey";

alter table "public"."zalara_jobs" add constraint "zalara_jobs_pkey" PRIMARY KEY using index "zalara_jobs_pkey";

alter table "public"."zalara_quotas" add constraint "zalara_quotas_pkey" PRIMARY KEY using index "zalara_quotas_pkey";

alter table "public"."zalara_templates" add constraint "zalara_templates_pkey" PRIMARY KEY using index "zalara_templates_pkey";

alter table "public"."zalara_webhooks" add constraint "zalara_webhooks_pkey" PRIMARY KEY using index "zalara_webhooks_pkey";

alter table "public"."engines" add constraint "engines_slug_key" UNIQUE using index "engines_slug_key";

alter table "public"."job_logs" add constraint "job_logs_job_id_fkey" FOREIGN KEY (job_id) REFERENCES public.jobs(id) ON DELETE CASCADE not valid;

alter table "public"."job_logs" validate constraint "job_logs_job_id_fkey";

alter table "public"."jobs" add constraint "jobs_engine_slug_fkey" FOREIGN KEY (engine_slug) REFERENCES public.engines(slug) not valid;

alter table "public"."jobs" validate constraint "jobs_engine_slug_fkey";

alter table "public"."kb_universes" add constraint "kb_universes_slug_key" UNIQUE using index "kb_universes_slug_key";

alter table "public"."zalara_campaigns" add constraint "zalara_campaigns_status_check" CHECK ((status = ANY (ARRAY['inactive'::text, 'active'::text, 'paused'::text]))) not valid;

alter table "public"."zalara_campaigns" validate constraint "zalara_campaigns_status_check";

alter table "public"."zalara_campaigns" add constraint "zalara_campaigns_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."zalara_campaigns" validate constraint "zalara_campaigns_user_id_fkey";

alter table "public"."zalara_jobs" add constraint "zalara_jobs_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'done'::text, 'failed'::text, 'dead'::text, 'cancelled'::text]))) not valid;

alter table "public"."zalara_jobs" validate constraint "zalara_jobs_status_check";

alter table "public"."zalara_jobs" add constraint "zalara_jobs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."zalara_jobs" validate constraint "zalara_jobs_user_id_fkey";

alter table "public"."zalara_quotas" add constraint "zalara_quotas_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."zalara_quotas" validate constraint "zalara_quotas_user_id_fkey";

alter table "public"."zalara_templates" add constraint "zalara_templates_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."zalara_templates" validate constraint "zalara_templates_owner_id_fkey";

alter table "public"."zalara_webhooks" add constraint "zalara_webhooks_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."zalara_webhooks" validate constraint "zalara_webhooks_user_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.kb_universes_set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$
;

grant delete on table "public"."engines" to "anon";

grant insert on table "public"."engines" to "anon";

grant references on table "public"."engines" to "anon";

grant select on table "public"."engines" to "anon";

grant trigger on table "public"."engines" to "anon";

grant truncate on table "public"."engines" to "anon";

grant update on table "public"."engines" to "anon";

grant delete on table "public"."engines" to "authenticated";

grant insert on table "public"."engines" to "authenticated";

grant references on table "public"."engines" to "authenticated";

grant select on table "public"."engines" to "authenticated";

grant trigger on table "public"."engines" to "authenticated";

grant truncate on table "public"."engines" to "authenticated";

grant update on table "public"."engines" to "authenticated";

grant delete on table "public"."engines" to "service_role";

grant insert on table "public"."engines" to "service_role";

grant references on table "public"."engines" to "service_role";

grant select on table "public"."engines" to "service_role";

grant trigger on table "public"."engines" to "service_role";

grant truncate on table "public"."engines" to "service_role";

grant update on table "public"."engines" to "service_role";

grant delete on table "public"."job_logs" to "anon";

grant insert on table "public"."job_logs" to "anon";

grant references on table "public"."job_logs" to "anon";

grant select on table "public"."job_logs" to "anon";

grant trigger on table "public"."job_logs" to "anon";

grant truncate on table "public"."job_logs" to "anon";

grant update on table "public"."job_logs" to "anon";

grant delete on table "public"."job_logs" to "authenticated";

grant insert on table "public"."job_logs" to "authenticated";

grant references on table "public"."job_logs" to "authenticated";

grant select on table "public"."job_logs" to "authenticated";

grant trigger on table "public"."job_logs" to "authenticated";

grant truncate on table "public"."job_logs" to "authenticated";

grant update on table "public"."job_logs" to "authenticated";

grant delete on table "public"."job_logs" to "service_role";

grant insert on table "public"."job_logs" to "service_role";

grant references on table "public"."job_logs" to "service_role";

grant select on table "public"."job_logs" to "service_role";

grant trigger on table "public"."job_logs" to "service_role";

grant truncate on table "public"."job_logs" to "service_role";

grant update on table "public"."job_logs" to "service_role";

grant delete on table "public"."jobs" to "anon";

grant insert on table "public"."jobs" to "anon";

grant references on table "public"."jobs" to "anon";

grant select on table "public"."jobs" to "anon";

grant trigger on table "public"."jobs" to "anon";

grant truncate on table "public"."jobs" to "anon";

grant update on table "public"."jobs" to "anon";

grant delete on table "public"."jobs" to "authenticated";

grant insert on table "public"."jobs" to "authenticated";

grant references on table "public"."jobs" to "authenticated";

grant select on table "public"."jobs" to "authenticated";

grant trigger on table "public"."jobs" to "authenticated";

grant truncate on table "public"."jobs" to "authenticated";

grant update on table "public"."jobs" to "authenticated";

grant delete on table "public"."jobs" to "service_role";

grant insert on table "public"."jobs" to "service_role";

grant references on table "public"."jobs" to "service_role";

grant select on table "public"."jobs" to "service_role";

grant trigger on table "public"."jobs" to "service_role";

grant truncate on table "public"."jobs" to "service_role";

grant update on table "public"."jobs" to "service_role";

grant delete on table "public"."kb_master_index" to "anon";

grant insert on table "public"."kb_master_index" to "anon";

grant references on table "public"."kb_master_index" to "anon";

grant select on table "public"."kb_master_index" to "anon";

grant trigger on table "public"."kb_master_index" to "anon";

grant truncate on table "public"."kb_master_index" to "anon";

grant update on table "public"."kb_master_index" to "anon";

grant delete on table "public"."kb_master_index" to "authenticated";

grant insert on table "public"."kb_master_index" to "authenticated";

grant references on table "public"."kb_master_index" to "authenticated";

grant select on table "public"."kb_master_index" to "authenticated";

grant trigger on table "public"."kb_master_index" to "authenticated";

grant truncate on table "public"."kb_master_index" to "authenticated";

grant update on table "public"."kb_master_index" to "authenticated";

grant delete on table "public"."kb_master_index" to "service_role";

grant insert on table "public"."kb_master_index" to "service_role";

grant references on table "public"."kb_master_index" to "service_role";

grant select on table "public"."kb_master_index" to "service_role";

grant trigger on table "public"."kb_master_index" to "service_role";

grant truncate on table "public"."kb_master_index" to "service_role";

grant update on table "public"."kb_master_index" to "service_role";

grant delete on table "public"."kb_snapshots" to "anon";

grant insert on table "public"."kb_snapshots" to "anon";

grant references on table "public"."kb_snapshots" to "anon";

grant select on table "public"."kb_snapshots" to "anon";

grant trigger on table "public"."kb_snapshots" to "anon";

grant truncate on table "public"."kb_snapshots" to "anon";

grant update on table "public"."kb_snapshots" to "anon";

grant delete on table "public"."kb_snapshots" to "authenticated";

grant insert on table "public"."kb_snapshots" to "authenticated";

grant references on table "public"."kb_snapshots" to "authenticated";

grant select on table "public"."kb_snapshots" to "authenticated";

grant trigger on table "public"."kb_snapshots" to "authenticated";

grant truncate on table "public"."kb_snapshots" to "authenticated";

grant update on table "public"."kb_snapshots" to "authenticated";

grant delete on table "public"."kb_snapshots" to "service_role";

grant insert on table "public"."kb_snapshots" to "service_role";

grant references on table "public"."kb_snapshots" to "service_role";

grant select on table "public"."kb_snapshots" to "service_role";

grant trigger on table "public"."kb_snapshots" to "service_role";

grant truncate on table "public"."kb_snapshots" to "service_role";

grant update on table "public"."kb_snapshots" to "service_role";

grant delete on table "public"."kb_snapshots_v2" to "anon";

grant insert on table "public"."kb_snapshots_v2" to "anon";

grant references on table "public"."kb_snapshots_v2" to "anon";

grant select on table "public"."kb_snapshots_v2" to "anon";

grant trigger on table "public"."kb_snapshots_v2" to "anon";

grant truncate on table "public"."kb_snapshots_v2" to "anon";

grant update on table "public"."kb_snapshots_v2" to "anon";

grant delete on table "public"."kb_snapshots_v2" to "authenticated";

grant insert on table "public"."kb_snapshots_v2" to "authenticated";

grant references on table "public"."kb_snapshots_v2" to "authenticated";

grant select on table "public"."kb_snapshots_v2" to "authenticated";

grant trigger on table "public"."kb_snapshots_v2" to "authenticated";

grant truncate on table "public"."kb_snapshots_v2" to "authenticated";

grant update on table "public"."kb_snapshots_v2" to "authenticated";

grant delete on table "public"."kb_snapshots_v2" to "service_role";

grant insert on table "public"."kb_snapshots_v2" to "service_role";

grant references on table "public"."kb_snapshots_v2" to "service_role";

grant select on table "public"."kb_snapshots_v2" to "service_role";

grant trigger on table "public"."kb_snapshots_v2" to "service_role";

grant truncate on table "public"."kb_snapshots_v2" to "service_role";

grant update on table "public"."kb_snapshots_v2" to "service_role";

grant delete on table "public"."kb_universes" to "anon";

grant insert on table "public"."kb_universes" to "anon";

grant references on table "public"."kb_universes" to "anon";

grant select on table "public"."kb_universes" to "anon";

grant trigger on table "public"."kb_universes" to "anon";

grant truncate on table "public"."kb_universes" to "anon";

grant update on table "public"."kb_universes" to "anon";

grant delete on table "public"."kb_universes" to "authenticated";

grant insert on table "public"."kb_universes" to "authenticated";

grant references on table "public"."kb_universes" to "authenticated";

grant select on table "public"."kb_universes" to "authenticated";

grant trigger on table "public"."kb_universes" to "authenticated";

grant truncate on table "public"."kb_universes" to "authenticated";

grant update on table "public"."kb_universes" to "authenticated";

grant delete on table "public"."kb_universes" to "service_role";

grant insert on table "public"."kb_universes" to "service_role";

grant references on table "public"."kb_universes" to "service_role";

grant select on table "public"."kb_universes" to "service_role";

grant trigger on table "public"."kb_universes" to "service_role";

grant truncate on table "public"."kb_universes" to "service_role";

grant update on table "public"."kb_universes" to "service_role";

grant delete on table "public"."waitlist_subscribers" to "anon";

grant insert on table "public"."waitlist_subscribers" to "anon";

grant references on table "public"."waitlist_subscribers" to "anon";

grant select on table "public"."waitlist_subscribers" to "anon";

grant trigger on table "public"."waitlist_subscribers" to "anon";

grant truncate on table "public"."waitlist_subscribers" to "anon";

grant update on table "public"."waitlist_subscribers" to "anon";

grant delete on table "public"."waitlist_subscribers" to "authenticated";

grant insert on table "public"."waitlist_subscribers" to "authenticated";

grant references on table "public"."waitlist_subscribers" to "authenticated";

grant select on table "public"."waitlist_subscribers" to "authenticated";

grant trigger on table "public"."waitlist_subscribers" to "authenticated";

grant truncate on table "public"."waitlist_subscribers" to "authenticated";

grant update on table "public"."waitlist_subscribers" to "authenticated";

grant delete on table "public"."waitlist_subscribers" to "service_role";

grant insert on table "public"."waitlist_subscribers" to "service_role";

grant references on table "public"."waitlist_subscribers" to "service_role";

grant select on table "public"."waitlist_subscribers" to "service_role";

grant trigger on table "public"."waitlist_subscribers" to "service_role";

grant truncate on table "public"."waitlist_subscribers" to "service_role";

grant update on table "public"."waitlist_subscribers" to "service_role";

grant delete on table "public"."zalara_audit" to "anon";

grant insert on table "public"."zalara_audit" to "anon";

grant references on table "public"."zalara_audit" to "anon";

grant select on table "public"."zalara_audit" to "anon";

grant trigger on table "public"."zalara_audit" to "anon";

grant truncate on table "public"."zalara_audit" to "anon";

grant update on table "public"."zalara_audit" to "anon";

grant delete on table "public"."zalara_audit" to "authenticated";

grant insert on table "public"."zalara_audit" to "authenticated";

grant references on table "public"."zalara_audit" to "authenticated";

grant select on table "public"."zalara_audit" to "authenticated";

grant trigger on table "public"."zalara_audit" to "authenticated";

grant truncate on table "public"."zalara_audit" to "authenticated";

grant update on table "public"."zalara_audit" to "authenticated";

grant delete on table "public"."zalara_audit" to "service_role";

grant insert on table "public"."zalara_audit" to "service_role";

grant references on table "public"."zalara_audit" to "service_role";

grant select on table "public"."zalara_audit" to "service_role";

grant trigger on table "public"."zalara_audit" to "service_role";

grant truncate on table "public"."zalara_audit" to "service_role";

grant update on table "public"."zalara_audit" to "service_role";

grant delete on table "public"."zalara_campaigns" to "anon";

grant insert on table "public"."zalara_campaigns" to "anon";

grant references on table "public"."zalara_campaigns" to "anon";

grant select on table "public"."zalara_campaigns" to "anon";

grant trigger on table "public"."zalara_campaigns" to "anon";

grant truncate on table "public"."zalara_campaigns" to "anon";

grant update on table "public"."zalara_campaigns" to "anon";

grant delete on table "public"."zalara_campaigns" to "authenticated";

grant insert on table "public"."zalara_campaigns" to "authenticated";

grant references on table "public"."zalara_campaigns" to "authenticated";

grant select on table "public"."zalara_campaigns" to "authenticated";

grant trigger on table "public"."zalara_campaigns" to "authenticated";

grant truncate on table "public"."zalara_campaigns" to "authenticated";

grant update on table "public"."zalara_campaigns" to "authenticated";

grant delete on table "public"."zalara_campaigns" to "service_role";

grant insert on table "public"."zalara_campaigns" to "service_role";

grant references on table "public"."zalara_campaigns" to "service_role";

grant select on table "public"."zalara_campaigns" to "service_role";

grant trigger on table "public"."zalara_campaigns" to "service_role";

grant truncate on table "public"."zalara_campaigns" to "service_role";

grant update on table "public"."zalara_campaigns" to "service_role";

grant delete on table "public"."zalara_jobs" to "anon";

grant insert on table "public"."zalara_jobs" to "anon";

grant references on table "public"."zalara_jobs" to "anon";

grant select on table "public"."zalara_jobs" to "anon";

grant trigger on table "public"."zalara_jobs" to "anon";

grant truncate on table "public"."zalara_jobs" to "anon";

grant update on table "public"."zalara_jobs" to "anon";

grant delete on table "public"."zalara_jobs" to "authenticated";

grant insert on table "public"."zalara_jobs" to "authenticated";

grant references on table "public"."zalara_jobs" to "authenticated";

grant select on table "public"."zalara_jobs" to "authenticated";

grant trigger on table "public"."zalara_jobs" to "authenticated";

grant truncate on table "public"."zalara_jobs" to "authenticated";

grant update on table "public"."zalara_jobs" to "authenticated";

grant delete on table "public"."zalara_jobs" to "service_role";

grant insert on table "public"."zalara_jobs" to "service_role";

grant references on table "public"."zalara_jobs" to "service_role";

grant select on table "public"."zalara_jobs" to "service_role";

grant trigger on table "public"."zalara_jobs" to "service_role";

grant truncate on table "public"."zalara_jobs" to "service_role";

grant update on table "public"."zalara_jobs" to "service_role";

grant delete on table "public"."zalara_quotas" to "anon";

grant insert on table "public"."zalara_quotas" to "anon";

grant references on table "public"."zalara_quotas" to "anon";

grant select on table "public"."zalara_quotas" to "anon";

grant trigger on table "public"."zalara_quotas" to "anon";

grant truncate on table "public"."zalara_quotas" to "anon";

grant update on table "public"."zalara_quotas" to "anon";

grant delete on table "public"."zalara_quotas" to "authenticated";

grant insert on table "public"."zalara_quotas" to "authenticated";

grant references on table "public"."zalara_quotas" to "authenticated";

grant select on table "public"."zalara_quotas" to "authenticated";

grant trigger on table "public"."zalara_quotas" to "authenticated";

grant truncate on table "public"."zalara_quotas" to "authenticated";

grant update on table "public"."zalara_quotas" to "authenticated";

grant delete on table "public"."zalara_quotas" to "service_role";

grant insert on table "public"."zalara_quotas" to "service_role";

grant references on table "public"."zalara_quotas" to "service_role";

grant select on table "public"."zalara_quotas" to "service_role";

grant trigger on table "public"."zalara_quotas" to "service_role";

grant truncate on table "public"."zalara_quotas" to "service_role";

grant update on table "public"."zalara_quotas" to "service_role";

grant delete on table "public"."zalara_templates" to "anon";

grant insert on table "public"."zalara_templates" to "anon";

grant references on table "public"."zalara_templates" to "anon";

grant select on table "public"."zalara_templates" to "anon";

grant trigger on table "public"."zalara_templates" to "anon";

grant truncate on table "public"."zalara_templates" to "anon";

grant update on table "public"."zalara_templates" to "anon";

grant delete on table "public"."zalara_templates" to "authenticated";

grant insert on table "public"."zalara_templates" to "authenticated";

grant references on table "public"."zalara_templates" to "authenticated";

grant select on table "public"."zalara_templates" to "authenticated";

grant trigger on table "public"."zalara_templates" to "authenticated";

grant truncate on table "public"."zalara_templates" to "authenticated";

grant update on table "public"."zalara_templates" to "authenticated";

grant delete on table "public"."zalara_templates" to "service_role";

grant insert on table "public"."zalara_templates" to "service_role";

grant references on table "public"."zalara_templates" to "service_role";

grant select on table "public"."zalara_templates" to "service_role";

grant trigger on table "public"."zalara_templates" to "service_role";

grant truncate on table "public"."zalara_templates" to "service_role";

grant update on table "public"."zalara_templates" to "service_role";

grant delete on table "public"."zalara_webhooks" to "anon";

grant insert on table "public"."zalara_webhooks" to "anon";

grant references on table "public"."zalara_webhooks" to "anon";

grant select on table "public"."zalara_webhooks" to "anon";

grant trigger on table "public"."zalara_webhooks" to "anon";

grant truncate on table "public"."zalara_webhooks" to "anon";

grant update on table "public"."zalara_webhooks" to "anon";

grant delete on table "public"."zalara_webhooks" to "authenticated";

grant insert on table "public"."zalara_webhooks" to "authenticated";

grant references on table "public"."zalara_webhooks" to "authenticated";

grant select on table "public"."zalara_webhooks" to "authenticated";

grant trigger on table "public"."zalara_webhooks" to "authenticated";

grant truncate on table "public"."zalara_webhooks" to "authenticated";

grant update on table "public"."zalara_webhooks" to "authenticated";

grant delete on table "public"."zalara_webhooks" to "service_role";

grant insert on table "public"."zalara_webhooks" to "service_role";

grant references on table "public"."zalara_webhooks" to "service_role";

grant select on table "public"."zalara_webhooks" to "service_role";

grant trigger on table "public"."zalara_webhooks" to "service_role";

grant truncate on table "public"."zalara_webhooks" to "service_role";

grant update on table "public"."zalara_webhooks" to "service_role";


  create policy "kb_snapshots_v2_insert_anon"
  on "public"."kb_snapshots_v2"
  as permissive
  for insert
  to anon
with check (true);



  create policy "kb_snapshots_v2_select_anon"
  on "public"."kb_snapshots_v2"
  as permissive
  for select
  to anon
using (true);



  create policy "campaigns_mutate_own"
  on "public"."zalara_campaigns"
  as permissive
  for all
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "campaigns_select_own"
  on "public"."zalara_campaigns"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "jobs_insert_own"
  on "public"."zalara_jobs"
  as permissive
  for insert
  to authenticated
with check ((user_id = auth.uid()));



  create policy "jobs_select_own"
  on "public"."zalara_jobs"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "quotas_select_own"
  on "public"."zalara_quotas"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "templates_mutate_own"
  on "public"."zalara_templates"
  as permissive
  for all
  to authenticated
using ((owner_id = auth.uid()))
with check ((owner_id = auth.uid()));



  create policy "templates_select_public_or_own"
  on "public"."zalara_templates"
  as permissive
  for select
  to authenticated
using (((public = true) OR (owner_id = auth.uid())));



  create policy "webhooks_mutate_own"
  on "public"."zalara_webhooks"
  as permissive
  for all
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "webhooks_select_own"
  on "public"."zalara_webhooks"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));


CREATE TRIGGER kb_universes_set_updated_at BEFORE UPDATE ON public.kb_universes FOR EACH ROW EXECUTE FUNCTION public.kb_universes_set_updated_at();


