create type semver as (version character varying);
create function split_semver as regexp_matches('1.0a', E'[a-z]+|[0-9]+|[.-]', 'g');
create function cast_semver_as_character_varying(semver as version) returns character varying as $$
  begin
    return 
  end
$$ language plpgsql;
create cast (semver as character varying) with function cast_semver_as_character_varying(semver);
create cast (semver as character varying) with function cast_character_varying_as_semver(character varying);
