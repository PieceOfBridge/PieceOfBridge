CREATE TABLE users
(
    id              serial       primary key,
    name            varchar(255) not null,
    email           varchar(255) not null unique,
    username        varchar(255) not null unique,
    password_hash   varchar(511) not null
);

CREATE TABLE project
(
    id              serial       primary key,
    title           varchar(255) not null,
    description     varchar(255),
    git_url         varchar(255) not null
);

CREATE TABLE users_project
(
    id              serial                                          primary key,
    user_id         int references users (id) on delete cascade     not null,
    project_id      int references project (id) on delete cascade   not null
);

CREATE TABLE sast_scan_list
(
    id              serial       primary key,
    title           varchar(255) not null,
    description     varchar(255),
    version         varchar(255) not null,
    status          boolean      not null default false,
    processing_time varchar(255) not null,
    result_url      varchar(255) not null
);

CREATE TABLE sast
(
    id              serial                                                  primary key,
    project_id      int references project (id) on delete cascade           not null,
    sast_scan_id    int references sast_scan_list (id) on delete cascade    not null
);

CREATE TABLE sca_scan_list
(
    id              serial       primary key,
    title           varchar(255) not null,
    description     varchar(255),
    version         varchar(255) not null,
    status          boolean      not null default false,
    processing_time varchar(255) not null,
    result_url      varchar(255) not null
);

CREATE TABLE sca
(
    id              serial                                                  primary key,
    project_id      int references project (id) on delete cascade           not null,
    sca_scan_id     int references sca_scan_list (id) on delete cascade     not null
);