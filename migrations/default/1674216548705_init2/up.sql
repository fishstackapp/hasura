SET check_function_bodies = false;
CREATE TABLE public.orders (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    client_name text NOT NULL,
    client_phone text NOT NULL,
    client_address text NOT NULL,
    status text DEFAULT 'NEW'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    comment text,
    payment_type text DEFAULT 'CARD'::text NOT NULL,
    payment_id integer,
    payment_status text
);
CREATE FUNCTION public.sum_by_order(orders_row public.orders) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
    SELECT SUM(m.price * om.amount)
    FROM orders_menu as om
    JOIN menu as m ON om.menu_id=m.id
    WHERE order_id=orders_row.id
$$;
CREATE TABLE public.admin (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    username text NOT NULL,
    password text NOT NULL
);
CREATE TABLE public.categories (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    title text NOT NULL,
    slug text NOT NULL
);
CREATE TABLE public.customers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text,
    phone text NOT NULL,
    address text,
    "twilioVerificationSid" text
);
CREATE VIEW public.last_week_orders AS
 SELECT date(timezone('Europe/Kiev'::text, o.created_at)) AS date,
    sum(public.sum_by_order(o.*)) AS sum,
    count(o.created_at) AS count
   FROM public.orders o
  WHERE (date(timezone('Europe/Kiev'::text, o.created_at)) > (now() - '7 days'::interval))
  GROUP BY (date(timezone('Europe/Kiev'::text, o.created_at)))
  ORDER BY (date(timezone('Europe/Kiev'::text, o.created_at)));
CREATE TABLE public.menu (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    image text NOT NULL,
    weight numeric,
    title text NOT NULL,
    descriptions text,
    price numeric NOT NULL,
    category_id uuid NOT NULL
);
CREATE TABLE public.order_status (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    label text NOT NULL
);
CREATE TABLE public.orders_menu (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    menu_id uuid NOT NULL,
    amount numeric DEFAULT '1'::numeric NOT NULL
);
CREATE TABLE public.payment_status (
    id text NOT NULL,
    label text NOT NULL
);
CREATE TABLE public.payment_types (
    id text NOT NULL,
    label text NOT NULL
);
CREATE TABLE public.settings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    snacks_category uuid
);
ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_username_key UNIQUE (username);
ALTER TABLE ONLY public.categories
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_phone_key UNIQUE (phone);
ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.menu
    ADD CONSTRAINT menu_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.order_status
    ADD CONSTRAINT order_status_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.orders_menu
    ADD CONSTRAINT orders_menu_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.payment_status
    ADD CONSTRAINT payment_status_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.payment_types
    ADD CONSTRAINT payment_types_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.settings
    ADD CONSTRAINT setting_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.orders_menu
    ADD CONSTRAINT orders_menu_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_payment_status_fkey FOREIGN KEY (payment_status) REFERENCES public.payment_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_payment_type_fkey FOREIGN KEY (payment_type) REFERENCES public.payment_types(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_status_fkey FOREIGN KEY (status) REFERENCES public.order_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
