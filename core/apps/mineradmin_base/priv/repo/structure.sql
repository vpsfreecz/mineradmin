--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: auth_backends; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE auth_backends (
    id integer NOT NULL,
    label character varying(255),
    module character varying(255),
    opts jsonb
);


--
-- Name: auth_backends_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE auth_backends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_backends_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE auth_backends_id_seq OWNED BY auth_backends.id;


--
-- Name: auth_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE auth_tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    token character varying(100) NOT NULL,
    valid_to timestamp without time zone,
    "interval" integer,
    lifetime integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: auth_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE auth_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE auth_tokens_id_seq OWNED BY auth_tokens.id;


--
-- Name: gpus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE gpus (
    id integer NOT NULL,
    user_id integer NOT NULL,
    node_id integer NOT NULL,
    vendor integer NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gpus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gpus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gpus_id_seq OWNED BY gpus.id;


--
-- Name: nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE nodes (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    domain character varying(255) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nodes_id_seq OWNED BY nodes.id;


--
-- Name: programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE programs (
    id integer NOT NULL,
    label character varying(255) NOT NULL,
    description character varying(255),
    module character varying(255) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE programs_id_seq OWNED BY programs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp without time zone
);


--
-- Name: user_program_gpus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_program_gpus (
    user_program_id integer,
    gpu_id integer
);


--
-- Name: user_program_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_program_logs (
    id integer NOT NULL,
    user_program_id integer NOT NULL,
    user_session_id integer,
    type integer NOT NULL,
    opts jsonb,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_program_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_program_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_program_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_program_logs_id_seq OWNED BY user_program_logs.id;


--
-- Name: user_programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_programs (
    id integer NOT NULL,
    user_id integer NOT NULL,
    program_id integer NOT NULL,
    node_id integer NOT NULL,
    label character varying(255) NOT NULL,
    cmdline character varying(255),
    active boolean DEFAULT false NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_programs_id_seq OWNED BY user_programs.id;


--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_sessions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    auth_method character varying(30) NOT NULL,
    opened_at timestamp without time zone NOT NULL,
    closed_at timestamp without time zone,
    last_request_at timestamp without time zone NOT NULL,
    auth_token_id integer,
    auth_token_str character varying(100),
    client_ip_addr character varying(50) NOT NULL,
    request_count integer DEFAULT 0 NOT NULL
);


--
-- Name: user_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_sessions_id_seq OWNED BY user_sessions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    login character varying(100) NOT NULL,
    password character varying(100),
    role integer NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    auth_backend_id integer
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: auth_backends id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY auth_backends ALTER COLUMN id SET DEFAULT nextval('auth_backends_id_seq'::regclass);


--
-- Name: auth_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY auth_tokens ALTER COLUMN id SET DEFAULT nextval('auth_tokens_id_seq'::regclass);


--
-- Name: gpus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gpus ALTER COLUMN id SET DEFAULT nextval('gpus_id_seq'::regclass);


--
-- Name: nodes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nodes ALTER COLUMN id SET DEFAULT nextval('nodes_id_seq'::regclass);


--
-- Name: programs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs ALTER COLUMN id SET DEFAULT nextval('programs_id_seq'::regclass);


--
-- Name: user_program_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_program_logs ALTER COLUMN id SET DEFAULT nextval('user_program_logs_id_seq'::regclass);


--
-- Name: user_programs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_programs ALTER COLUMN id SET DEFAULT nextval('user_programs_id_seq'::regclass);


--
-- Name: user_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_sessions ALTER COLUMN id SET DEFAULT nextval('user_sessions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: auth_backends auth_backends_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY auth_backends
    ADD CONSTRAINT auth_backends_pkey PRIMARY KEY (id);


--
-- Name: auth_tokens auth_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY auth_tokens
    ADD CONSTRAINT auth_tokens_pkey PRIMARY KEY (id);


--
-- Name: gpus gpus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gpus
    ADD CONSTRAINT gpus_pkey PRIMARY KEY (id);


--
-- Name: nodes nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT nodes_pkey PRIMARY KEY (id);


--
-- Name: programs programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: user_program_logs user_program_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_program_logs
    ADD CONSTRAINT user_program_logs_pkey PRIMARY KEY (id);


--
-- Name: user_programs user_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_programs
    ADD CONSTRAINT user_programs_pkey PRIMARY KEY (id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: auth_tokens_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX auth_tokens_token_index ON auth_tokens USING btree (token);


--
-- Name: gpus_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX gpus_name_index ON gpus USING btree (name);


--
-- Name: gpus_node_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX gpus_node_id_index ON gpus USING btree (node_id);


--
-- Name: gpus_node_id_uuid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX gpus_node_id_uuid_index ON gpus USING btree (node_id, uuid);


--
-- Name: gpus_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX gpus_user_id_index ON gpus USING btree (user_id);


--
-- Name: gpus_vendor_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX gpus_vendor_index ON gpus USING btree (vendor);


--
-- Name: nodes_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX nodes_name_unique ON nodes USING btree (name, domain);


--
-- Name: user_program_gpus_gpu_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_program_gpus_gpu_id_index ON user_program_gpus USING btree (gpu_id);


--
-- Name: user_program_gpus_user_program_id_gpu_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_program_gpus_user_program_id_gpu_id_index ON user_program_gpus USING btree (user_program_id, gpu_id);


--
-- Name: user_program_gpus_user_program_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_program_gpus_user_program_id_index ON user_program_gpus USING btree (user_program_id);


--
-- Name: user_program_logs_user_program_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_program_logs_user_program_id_index ON user_program_logs USING btree (user_program_id);


--
-- Name: user_program_logs_user_session_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_program_logs_user_session_id_index ON user_program_logs USING btree (user_session_id);


--
-- Name: user_programs_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_programs_active_index ON user_programs USING btree (active);


--
-- Name: user_programs_node_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_programs_node_id_index ON user_programs USING btree (node_id);


--
-- Name: user_programs_program_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_programs_program_id_index ON user_programs USING btree (program_id);


--
-- Name: user_programs_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_programs_user_id_index ON user_programs USING btree (user_id);


--
-- Name: user_sessions_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_sessions_user_id_index ON user_sessions USING btree (user_id);


--
-- Name: users_login_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_login_index ON users USING btree (login);


--
-- Name: auth_tokens auth_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY auth_tokens
    ADD CONSTRAINT auth_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: gpus gpus_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gpus
    ADD CONSTRAINT gpus_node_id_fkey FOREIGN KEY (node_id) REFERENCES nodes(id);


--
-- Name: gpus gpus_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gpus
    ADD CONSTRAINT gpus_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_program_gpus user_program_gpus_gpu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_program_gpus
    ADD CONSTRAINT user_program_gpus_gpu_id_fkey FOREIGN KEY (gpu_id) REFERENCES gpus(id);


--
-- Name: user_program_gpus user_program_gpus_user_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_program_gpus
    ADD CONSTRAINT user_program_gpus_user_program_id_fkey FOREIGN KEY (user_program_id) REFERENCES user_programs(id) ON DELETE CASCADE;


--
-- Name: user_program_logs user_program_logs_user_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_program_logs
    ADD CONSTRAINT user_program_logs_user_program_id_fkey FOREIGN KEY (user_program_id) REFERENCES user_programs(id) ON DELETE CASCADE;


--
-- Name: user_program_logs user_program_logs_user_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_program_logs
    ADD CONSTRAINT user_program_logs_user_session_id_fkey FOREIGN KEY (user_session_id) REFERENCES user_sessions(id) ON DELETE CASCADE;


--
-- Name: user_programs user_programs_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_programs
    ADD CONSTRAINT user_programs_node_id_fkey FOREIGN KEY (node_id) REFERENCES nodes(id);


--
-- Name: user_programs user_programs_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_programs
    ADD CONSTRAINT user_programs_program_id_fkey FOREIGN KEY (program_id) REFERENCES programs(id);


--
-- Name: user_programs user_programs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_programs
    ADD CONSTRAINT user_programs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_sessions user_sessions_auth_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_sessions
    ADD CONSTRAINT user_sessions_auth_token_id_fkey FOREIGN KEY (auth_token_id) REFERENCES auth_tokens(id);


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: users users_auth_backend_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_auth_backend_id_fkey FOREIGN KEY (auth_backend_id) REFERENCES auth_backends(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO "schema_migrations" (version) VALUES (20170707195040), (20170708131738), (20170710154559), (20170714165502), (20170717071017), (20170725072832), (20170801065514), (20170802070021);

