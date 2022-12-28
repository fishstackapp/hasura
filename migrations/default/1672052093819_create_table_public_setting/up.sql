CREATE TABLE "public"."setting" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "drinks_categoty" uuid NOT NULL, PRIMARY KEY ("id") );
CREATE EXTENSION IF NOT EXISTS pgcrypto;
