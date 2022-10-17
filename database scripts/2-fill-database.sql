--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5 (Ubuntu 14.5-1.pgdg20.04+1)
-- Dumped by pg_dump version 14.3

-- Started on 2022-10-17 03:49:10 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 9 (class 2615 OID 16438)
-- Name: catloader; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA catloader;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 216 (class 1259 OID 16440)
-- Name: tbl_auth; Type: TABLE; Schema: catloader; Owner: -
--

CREATE TABLE catloader.tbl_auth (
    aut_id bigint NOT NULL,
    aut_email character varying(255) NOT NULL,
    aut_key character varying(128) NOT NULL,
    aut_isvalid boolean DEFAULT true NOT NULL,
    aut_confirmed boolean DEFAULT false,
    aut_timestamp timestamp with time zone DEFAULT now()
);


--
-- TOC entry 217 (class 1259 OID 16446)
-- Name: tbl_auth_aut_id_seq; Type: SEQUENCE; Schema: catloader; Owner: -
--

ALTER TABLE catloader.tbl_auth ALTER COLUMN aut_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME catloader.tbl_auth_aut_id_seq
    START WITH 10
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 218 (class 1259 OID 16447)
-- Name: tbl_image; Type: TABLE; Schema: catloader; Owner: -
--

CREATE TABLE catloader.tbl_image (
    img_id bigint NOT NULL,
    img_name character varying(124),
    img_caption character varying(255),
    img_filename character varying(255) NOT NULL,
    img_tstamp timestamp with time zone DEFAULT now() NOT NULL,
    img_onair boolean DEFAULT true NOT NULL,
    aut_id bigint NOT NULL,
    img_width bigint DEFAULT 0 NOT NULL,
    img_height bigint DEFAULT 0 NOT NULL,
    img_th_left bigint DEFAULT 0 NOT NULL,
    img_th_top bigint DEFAULT 0 NOT NULL,
    img_th_right bigint DEFAULT 0 NOT NULL,
    img_th_bottom bigint DEFAULT 0 NOT NULL,
    img_th_filename character varying(255) NOT NULL,
    img_is_valid boolean
);


--
-- TOC entry 4579 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tbl_image.aut_id; Type: COMMENT; Schema: catloader; Owner: -
--

COMMENT ON COLUMN catloader.tbl_image.aut_id IS 'owner of the image';


--
-- TOC entry 219 (class 1259 OID 16461)
-- Name: tbl_image_img_id_seq; Type: SEQUENCE; Schema: catloader; Owner: -
--

ALTER TABLE catloader.tbl_image ALTER COLUMN img_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME catloader.tbl_image_img_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 16462)
-- Name: tbl_likes; Type: TABLE; Schema: catloader; Owner: -
--

CREATE TABLE catloader.tbl_likes (
    aut_id bigint NOT NULL,
    img_id bigint NOT NULL
);


--
-- TOC entry 4580 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE tbl_likes; Type: COMMENT; Schema: catloader; Owner: -
--

COMMENT ON TABLE catloader.tbl_likes IS 'a record in this table means: the user (aut_id) likes the image (img_id)';


--
-- TOC entry 291 (class 1259 OID 17392)
-- Name: tbl_log_ai; Type: TABLE; Schema: catloader; Owner: -
--

CREATE TABLE catloader.tbl_log_ai (
    lai_id bigint NOT NULL,
    img_id bigint NOT NULL,
    lai_tagres_full_image text,
    lai_tagres_thumb text,
    aut_id bigint NOT NULL,
    lai_timestmp timestamp with time zone DEFAULT now()
);


--
-- TOC entry 292 (class 1259 OID 17400)
-- Name: tbl_log_ai_lai_id_seq; Type: SEQUENCE; Schema: catloader; Owner: -
--

ALTER TABLE catloader.tbl_log_ai ALTER COLUMN lai_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME catloader.tbl_log_ai_lai_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 16465)
-- Name: v_like_count; Type: VIEW; Schema: catloader; Owner: -
--

CREATE VIEW catloader.v_like_count AS
 SELECT tbl_likes.img_id,
    count(tbl_likes.aut_id) AS how_many
   FROM catloader.tbl_likes
  GROUP BY tbl_likes.img_id;


--
-- TOC entry 293 (class 1259 OID 17407)
-- Name: v_image; Type: VIEW; Schema: catloader; Owner: -
--

CREATE VIEW catloader.v_image AS
 SELECT tbl_image.img_id,
    tbl_image.img_name,
    tbl_image.img_caption,
    tbl_image.img_filename,
    tbl_image.img_tstamp,
    tbl_image.img_onair,
    tbl_image.aut_id,
    tbl_image.img_width,
    tbl_image.img_height,
    tbl_image.img_th_left,
    tbl_image.img_th_top,
    tbl_image.img_th_right,
    tbl_image.img_th_bottom,
    tbl_image.img_th_filename,
    tbl_image.img_is_valid,
    u.aut_email,
    COALESCE(v_like_count.how_many, (0)::bigint) AS likes
   FROM ((catloader.tbl_image
     JOIN catloader.tbl_auth u USING (aut_id))
     LEFT JOIN catloader.v_like_count USING (img_id));


--
-- TOC entry 4399 (class 2606 OID 16942)
-- Name: tbl_auth tbl_auth_pkey; Type: CONSTRAINT; Schema: catloader; Owner: -
--

ALTER TABLE ONLY catloader.tbl_auth
    ADD CONSTRAINT tbl_auth_pkey PRIMARY KEY (aut_id);


--
-- TOC entry 4402 (class 2606 OID 16944)
-- Name: tbl_image tbl_image_pkey; Type: CONSTRAINT; Schema: catloader; Owner: -
--

ALTER TABLE ONLY catloader.tbl_image
    ADD CONSTRAINT tbl_image_pkey PRIMARY KEY (img_id);


--
-- TOC entry 4406 (class 2606 OID 16946)
-- Name: tbl_likes tbl_likes_aut_id_img_id_key; Type: CONSTRAINT; Schema: catloader; Owner: -
--

ALTER TABLE ONLY catloader.tbl_likes
    ADD CONSTRAINT tbl_likes_aut_id_img_id_key UNIQUE (aut_id, img_id);


--
-- TOC entry 4408 (class 2606 OID 17399)
-- Name: tbl_log_ai tbl_log_ai_pkey; Type: CONSTRAINT; Schema: catloader; Owner: -
--

ALTER TABLE ONLY catloader.tbl_log_ai
    ADD CONSTRAINT tbl_log_ai_pkey PRIMARY KEY (lai_id);


--
-- TOC entry 4400 (class 1259 OID 17406)
-- Name: fki_tbl_image_aut_id_fkey; Type: INDEX; Schema: catloader; Owner: -
--

CREATE INDEX fki_tbl_image_aut_id_fkey ON catloader.tbl_image USING btree (aut_id);


--
-- TOC entry 4403 (class 1259 OID 17031)
-- Name: fki_tbl_likes_aut_id_fkey; Type: INDEX; Schema: catloader; Owner: -
--

CREATE INDEX fki_tbl_likes_aut_id_fkey ON catloader.tbl_likes USING btree (aut_id);


--
-- TOC entry 4404 (class 1259 OID 17032)
-- Name: fki_tbl_likes_img_id_fkey; Type: INDEX; Schema: catloader; Owner: -
--

CREATE INDEX fki_tbl_likes_img_id_fkey ON catloader.tbl_likes USING btree (img_id);


--
-- TOC entry 4409 (class 2606 OID 17401)
-- Name: tbl_image tbl_image_aut_id_fkey; Type: FK CONSTRAINT; Schema: catloader; Owner: -
--

ALTER TABLE ONLY catloader.tbl_image
    ADD CONSTRAINT tbl_image_aut_id_fkey FOREIGN KEY (aut_id) REFERENCES catloader.tbl_auth(aut_id) ON DELETE CASCADE NOT VALID;


--
-- TOC entry 4410 (class 2606 OID 17062)
-- Name: tbl_likes tbl_likes_aut_id_fkey; Type: FK CONSTRAINT; Schema: catloader; Owner: -
--

ALTER TABLE ONLY catloader.tbl_likes
    ADD CONSTRAINT tbl_likes_aut_id_fkey FOREIGN KEY (aut_id) REFERENCES catloader.tbl_auth(aut_id) ON DELETE CASCADE NOT VALID;


--
-- TOC entry 4411 (class 2606 OID 17067)
-- Name: tbl_likes tbl_likes_img_id_fkey; Type: FK CONSTRAINT; Schema: catloader; Owner: -
--

ALTER TABLE ONLY catloader.tbl_likes
    ADD CONSTRAINT tbl_likes_img_id_fkey FOREIGN KEY (img_id) REFERENCES catloader.tbl_image(img_id) ON DELETE CASCADE NOT VALID;


-- Completed on 2022-10-17 03:49:18 CEST

--
-- PostgreSQL database dump complete
--


