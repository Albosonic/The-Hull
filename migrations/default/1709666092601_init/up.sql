CREATE USER hasurauser WITH PASSWORD 'hasurauser';
GRANT USAGE ON SCHEMA public TO hasurauser;
CREATE SCHEMA IF NOT EXISTS hdb_catalog;

SET check_function_bodies = false;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
CREATE FUNCTION public.add_monotonic_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
nextval bigint;
BEGIN
  PERFORM pg_advisory_xact_lock(1);
  select nextval('serial_chats') into nextval;
  NEW.id := nextval;
  RETURN NEW;
END;
$$;
CREATE FUNCTION public.add_monotonic_id_ints() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
nextval bigint;
BEGIN
  PERFORM pg_advisory_xact_lock(1);
  select nextval('serial_chats') into nextval;
  NEW.id := nextval;
  RETURN NEW;
END;
$$;
CREATE TABLE public.bio (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "memberId" uuid NOT NULL,
    bio text NOT NULL
);
COMMENT ON TABLE public.bio IS 'Self written bios by members';
CREATE TABLE public.comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "parentId" uuid,
    "eventId" uuid,
    "raceId" uuid,
    img text,
    "createdAt" timestamp with time zone NOT NULL,
    "memberId" uuid NOT NULL,
    comment text NOT NULL
);
COMMENT ON TABLE public.comments IS 'member comments';
CREATE TABLE public.commodores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    yacht_club uuid NOT NULL,
    member_id uuid NOT NULL,
    active boolean DEFAULT false NOT NULL
);
COMMENT ON TABLE public.commodores IS 'Commodores';
CREATE TABLE public.messages (
    id integer NOT NULL,
    "roomId" uuid NOT NULL,
    "authorId" uuid NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone NOT NULL
);
COMMENT ON TABLE public.messages IS 'user messages';
CREATE TABLE public.potential_members (
    email text NOT NULL,
    "firstName" text NOT NULL,
    "lastName" text NOT NULL,
    yacht_club uuid NOT NULL,
    "referredBy" text,
    "secondEmail" text,
    "secondFirstName" text,
    "secondLastName" text,
    "membershipDenied" boolean DEFAULT false NOT NULL,
    "profilePic" text
);
COMMENT ON TABLE public.potential_members IS 'yacht club member applicants';
CREATE TABLE public.race_chairs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "memberId" uuid NOT NULL,
    "ycId" uuid NOT NULL
);
COMMENT ON TABLE public.race_chairs IS 'yacht club race chairs';
CREATE TABLE public.race_courses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "courseName" text NOT NULL,
    instructions jsonb NOT NULL,
    "ycId" uuid NOT NULL
);
COMMENT ON TABLE public.race_courses IS 'user uploaded race courses';
CREATE TABLE public.race_release_forms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    content text NOT NULL,
    "yachtClubId" uuid,
    name text DEFAULT 'Standard Race Release'::text NOT NULL
);
COMMENT ON TABLE public.race_release_forms IS 'release forms for races';
CREATE TABLE public.race_series (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "seriesName" text NOT NULL,
    "ycId" uuid NOT NULL
);
COMMENT ON TABLE public.race_series IS 'races are gouped by series';
CREATE TABLE public.race_tickets_for_purchase (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "raceId" uuid NOT NULL,
    "ycId" uuid NOT NULL,
    cost integer
);
COMMENT ON TABLE public.race_tickets_for_purchase IS 'tickets for purchase';
CREATE TABLE public.race_tickets_purchased (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "raceTicketId" uuid NOT NULL,
    "ycId" uuid NOT NULL,
    "memberId" uuid NOT NULL,
    "raceId" uuid NOT NULL,
    paid boolean DEFAULT false NOT NULL
);
COMMENT ON TABLE public.race_tickets_purchased IS 'purchased race tickets';
CREATE TABLE public.races (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "ycId" uuid NOT NULL,
    "raceName" text NOT NULL,
    "eventId" uuid,
    "startDate" date NOT NULL,
    "raceCourseId" uuid,
    img text,
    "endDate" date NOT NULL,
    "seriesId" uuid,
    "startTime" text NOT NULL,
    "endTime" text NOT NULL,
    "raceTicketId" uuid,
    "releaseFormId" uuid,
    commentary text
);
CREATE TABLE public.reciprocal_request (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "memberId" uuid NOT NULL,
    "homeYCId" uuid NOT NULL,
    "visitingYCId" uuid NOT NULL,
    "visitingDate" date NOT NULL,
    "requestingSlip" boolean DEFAULT false,
    "vesselId" uuid,
    "specialNotes" text,
    "unafilliatedVesselId" uuid,
    status text DEFAULT 'pending'::text NOT NULL,
    "letterSent" date
);
COMMENT ON TABLE public.reciprocal_request IS 'Reciprocal request and their status';
CREATE TABLE public.regions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL
);
COMMENT ON TABLE public.regions IS 'Regions';
CREATE SEQUENCE public.serial_chats
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public.serial_chats3
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE TABLE public.signed_race_release (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "memberId" uuid NOT NULL,
    "releaseFormId" uuid NOT NULL,
    signature text NOT NULL
);
COMMENT ON TABLE public.signed_race_release IS 'signed race release forms';
CREATE TABLE public.standard_daily_yc_info (
    id uuid NOT NULL,
    hours text,
    "dayOfWeek" text,
    food text,
    entertainment text
);
COMMENT ON TABLE public.standard_daily_yc_info IS 'standard yacht club info';
CREATE TABLE public.user_rooms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "memberId" uuid NOT NULL,
    "lastSeen" date,
    "recipientId" uuid NOT NULL,
    "yachtClubId" uuid NOT NULL,
    "newMessage" uuid
);
COMMENT ON TABLE public.user_rooms IS 'members of chat rooms rooms';
CREATE TABLE public.vessels (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "vesselName" text,
    "ownerId" uuid NOT NULL,
    "insuranceInfo" jsonb DEFAULT jsonb_build_object(),
    "specialNotes" text,
    img text,
    length integer,
    beam integer,
    draft double precision,
    type text,
    "hullMaterial" text,
    "unafilliatedVesselId" uuid,
    make text,
    model text,
    "sailNumber" integer,
    marina text,
    slip text
);
COMMENT ON TABLE public.vessels IS 'Vessels and related info';
CREATE TABLE public.yacht_clubs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    region uuid NOT NULL,
    logo text
);
COMMENT ON TABLE public.yacht_clubs IS 'Yacht Club';
CREATE TABLE public.yc_event_dinner_tickets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "eventId" uuid NOT NULL,
    "memberId" uuid NOT NULL,
    "ticketForPurchaseId" uuid NOT NULL,
    paid boolean DEFAULT false
);
COMMENT ON TABLE public.yc_event_dinner_tickets IS 'Event Dinner Tickets';
CREATE TABLE public.yc_event_purchased_tickets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "ticketForPurchaseId" uuid NOT NULL,
    "memberId" uuid NOT NULL,
    paid boolean DEFAULT false NOT NULL,
    "eventId" uuid NOT NULL
);
COMMENT ON TABLE public.yc_event_purchased_tickets IS 'tickets which have been purchased';
CREATE TABLE public.yc_event_tickets_for_purchase (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "ycId" uuid NOT NULL,
    "eventId" uuid NOT NULL,
    cost integer,
    "dinnerCost" integer
);
COMMENT ON TABLE public.yc_event_tickets_for_purchase IS 'yacht club event tickets for purchase';
CREATE TABLE public.yc_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_name text NOT NULL,
    entertainment text,
    special_club_hours text,
    "raceId" uuid,
    "ycId" uuid NOT NULL,
    hours text,
    date text,
    image text,
    location text DEFAULT 'The club'::text,
    "specialNotes" text,
    "startDate" date NOT NULL,
    "endDate" date NOT NULL,
    "startTime" text NOT NULL,
    "endTime" text NOT NULL
);
COMMENT ON TABLE public.yc_events IS 'yacht club Events';
CREATE TABLE public.yc_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text,
    yacht_club uuid NOT NULL,
    email text NOT NULL,
    "firstName" text,
    "lastName" text,
    "secondFirstName" text,
    "secondLastName" text,
    "secondName" text,
    "secondEmail" text,
    active boolean DEFAULT true NOT NULL,
    "duesOwed" integer DEFAULT 0,
    bio text,
    "profilePic" text,
    "isRacer" boolean DEFAULT false,
    "lastLogin" date
);
COMMENT ON TABLE public.yc_members IS 'yacht club members';
CREATE TABLE public.yc_secondary_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    "firstName" text NOT NULL,
    "lastName" text NOT NULL,
    name text NOT NULL,
    "primaryMemberId" uuid NOT NULL
);
COMMENT ON TABLE public.yc_secondary_members IS 'non primary yacht club members';
ALTER TABLE ONLY public.bio
    ADD CONSTRAINT "Bio_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.commodores
    ADD CONSTRAINT commodores_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.potential_members
    ADD CONSTRAINT "potential_members_email_secondEmail_key" UNIQUE (email, "secondEmail");
ALTER TABLE ONLY public.potential_members
    ADD CONSTRAINT potential_members_pkey PRIMARY KEY (email);
ALTER TABLE ONLY public.race_chairs
    ADD CONSTRAINT "race_chairs_memberId_key" UNIQUE ("memberId");
ALTER TABLE ONLY public.race_chairs
    ADD CONSTRAINT race_chairs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.race_courses
    ADD CONSTRAINT race_courses_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.race_series
    ADD CONSTRAINT race_series_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.race_tickets_for_purchase
    ADD CONSTRAINT race_tickets_for_purchase_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.race_tickets_for_purchase
    ADD CONSTRAINT "race_tickets_for_purchase_raceId_key" UNIQUE ("raceId");
ALTER TABLE ONLY public.race_tickets_purchased
    ADD CONSTRAINT race_tickets_purchased_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.reciprocal_request
    ADD CONSTRAINT reciprocal_request_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.race_release_forms
    ADD CONSTRAINT release_forms_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.signed_race_release
    ADD CONSTRAINT signed_race_release_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.standard_daily_yc_info
    ADD CONSTRAINT standard_yc_info_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.user_rooms
    ADD CONSTRAINT user_rooms_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.vessels
    ADD CONSTRAINT vessels_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.yacht_clubs
    ADD CONSTRAINT yacht_club_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.yc_event_dinner_tickets
    ADD CONSTRAINT yc_event_dinner_tickets_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.yc_event_purchased_tickets
    ADD CONSTRAINT yc_event_purchased_tickets_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.yc_event_tickets_for_purchase
    ADD CONSTRAINT "yc_event_tickets_for_purchase_eventId_key" UNIQUE ("eventId");
ALTER TABLE ONLY public.yc_event_tickets_for_purchase
    ADD CONSTRAINT yc_event_tickets_for_purchase_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.yc_events
    ADD CONSTRAINT yc_events_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.yc_members
    ADD CONSTRAINT yc_members_email_key UNIQUE (email);
ALTER TABLE ONLY public.yc_members
    ADD CONSTRAINT yc_members_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.yc_secondary_members
    ADD CONSTRAINT yc_secondary_members_email_key UNIQUE (email);
ALTER TABLE ONLY public.yc_secondary_members
    ADD CONSTRAINT yc_secondary_members_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.yc_secondary_members
    ADD CONSTRAINT "yc_secondary_members_primaryMemberId_key" UNIQUE ("primaryMemberId");
CREATE TRIGGER add_monotonic_id_ints_trigger BEFORE INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION public.add_monotonic_id_ints();
ALTER TABLE ONLY public.bio
    ADD CONSTRAINT "Bio_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES public.yc_events(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_raceId_fkey" FOREIGN KEY ("raceId") REFERENCES public.races(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.commodores
    ADD CONSTRAINT commodores_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.commodores
    ADD CONSTRAINT commodores_yacht_club_fkey FOREIGN KEY (yacht_club) REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "messages_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "messages_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES public.user_rooms(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.potential_members
    ADD CONSTRAINT potential_members_yacht_club_fkey FOREIGN KEY (yacht_club) REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.race_chairs
    ADD CONSTRAINT "race_chairs_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.race_chairs
    ADD CONSTRAINT "race_chairs_ycId_fkey" FOREIGN KEY ("ycId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.race_courses
    ADD CONSTRAINT "race_courses_ycId_fkey" FOREIGN KEY ("ycId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.race_series
    ADD CONSTRAINT "race_series_ycId_fkey" FOREIGN KEY ("ycId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.race_tickets_for_purchase
    ADD CONSTRAINT "race_tickets_for_purchase_raceId_fkey" FOREIGN KEY ("raceId") REFERENCES public.races(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.race_tickets_for_purchase
    ADD CONSTRAINT "race_tickets_for_purchase_ycId_fkey" FOREIGN KEY ("ycId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.race_tickets_purchased
    ADD CONSTRAINT "race_tickets_purchased_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.race_tickets_purchased
    ADD CONSTRAINT "race_tickets_purchased_raceId_fkey" FOREIGN KEY ("raceId") REFERENCES public.races(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.race_tickets_purchased
    ADD CONSTRAINT "race_tickets_purchased_raceTicketId_fkey" FOREIGN KEY ("raceTicketId") REFERENCES public.race_tickets_for_purchase(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.race_tickets_purchased
    ADD CONSTRAINT "race_tickets_purchased_ycId_fkey" FOREIGN KEY ("ycId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.races
    ADD CONSTRAINT "races_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES public.yc_events(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.races
    ADD CONSTRAINT "races_raceCourseId_fkey" FOREIGN KEY ("raceCourseId") REFERENCES public.race_courses(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.races
    ADD CONSTRAINT "races_releaseFormId_fkey" FOREIGN KEY ("releaseFormId") REFERENCES public.race_release_forms(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.races
    ADD CONSTRAINT "races_seriesId_fkey" FOREIGN KEY ("seriesId") REFERENCES public.race_series(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.races
    ADD CONSTRAINT "races_ycId_fkey" FOREIGN KEY ("ycId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.reciprocal_request
    ADD CONSTRAINT "reciprocal_request_homeYCId_fkey" FOREIGN KEY ("homeYCId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.reciprocal_request
    ADD CONSTRAINT "reciprocal_request_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.reciprocal_request
    ADD CONSTRAINT "reciprocal_request_visitingYCId_fkey" FOREIGN KEY ("visitingYCId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.race_release_forms
    ADD CONSTRAINT "release_forms_yachtClubId_fkey" FOREIGN KEY ("yachtClubId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.signed_race_release
    ADD CONSTRAINT "signed_race_release_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.signed_race_release
    ADD CONSTRAINT "signed_race_release_releaseFormId_fkey" FOREIGN KEY ("releaseFormId") REFERENCES public.race_release_forms(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.standard_daily_yc_info
    ADD CONSTRAINT standard_yc_info_id_fkey FOREIGN KEY (id) REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.user_rooms
    ADD CONSTRAINT "user_rooms_yachtClubId_fkey" FOREIGN KEY ("yachtClubId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.vessels
    ADD CONSTRAINT "vessels_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yacht_clubs
    ADD CONSTRAINT yacht_club_region_fkey FOREIGN KEY (region) REFERENCES public.regions(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yc_event_dinner_tickets
    ADD CONSTRAINT "yc_event_dinner_tickets_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES public.yc_events(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yc_event_dinner_tickets
    ADD CONSTRAINT "yc_event_dinner_tickets_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yc_event_dinner_tickets
    ADD CONSTRAINT "yc_event_dinner_tickets_ticketForPurchaseId_fkey" FOREIGN KEY ("ticketForPurchaseId") REFERENCES public.yc_event_tickets_for_purchase(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yc_event_purchased_tickets
    ADD CONSTRAINT "yc_event_purchased_tickets_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES public.yc_events(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yc_event_purchased_tickets
    ADD CONSTRAINT "yc_event_purchased_tickets_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yc_event_purchased_tickets
    ADD CONSTRAINT "yc_event_purchased_tickets_ticketForPurchaseId_fkey" FOREIGN KEY ("ticketForPurchaseId") REFERENCES public.yc_event_tickets_for_purchase(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yc_event_tickets_for_purchase
    ADD CONSTRAINT "yc_event_tickets_for_purchase_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES public.yc_events(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yc_event_tickets_for_purchase
    ADD CONSTRAINT "yc_event_tickets_for_purchase_ycId_fkey" FOREIGN KEY ("ycId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yc_events
    ADD CONSTRAINT "yc_events_ycId_fkey" FOREIGN KEY ("ycId") REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yc_members
    ADD CONSTRAINT yc_members_yacht_club_fkey FOREIGN KEY (yacht_club) REFERENCES public.yacht_clubs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.yc_secondary_members
    ADD CONSTRAINT "yc_secondary_members_primaryMemberId_fkey" FOREIGN KEY ("primaryMemberId") REFERENCES public.yc_members(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
