-- Clipboards 
--
-- Simple object clipboard plpgsql procedures
-- 
-- Copyright (C) 2003 Jeff Davis
-- @author Jeff Davis davis@xarg.net
-- @creation-date 10/22/2003
--
-- @cvs-id $Id$
--
-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html

create or replace function clipboard__new (integer,integer,varchar,integer,timestamptz,integer,varchar,integer)
returns integer as '
declare
  p_clipboard_id                        alias for $1;       -- default null
  p_owner_id                            alias for $2;       -- default null
  p_title                               alias for $3;
  p_package_id                          alias for $4;
  p_creation_date                       alias for $5;       -- default now()
  p_creation_user                       alias for $6;       -- default null
  p_creation_ip                         alias for $7;       -- default null
  p_context_id                          alias for $8;       -- default null
  v_clipboard_id                                     clipboards.clipboard_id%TYPE;
begin
    v_clipboard_id := acs_object__new (
                           p_clipboard_id,
                           ''clipboard'',
                           p_creation_date,
                           p_creation_user,
                           p_creation_ip,
                           p_context_id,
                           ''t'',
                           p_title,
                           p_package_id);

    insert into clipboards (clipboard_id, owner_id)
    values (v_clipboard_id, p_owner_id);

    PERFORM acs_permission__grant_permission(
            v_clipboard_id,
            p_owner_id,
            ''admin'');

    return v_clipboard_id;

end;' language 'plpgsql';

select define_function_args('clipboard__new','clipboard_id,owner_id,title,package_id,creation_date,creation_user,creation_ip,context_id');

create or replace function clipboard__delete (integer)
returns integer as '
declare
  p_clipboard_id                             alias for $1;
begin
    if exists (select 1 from acs_objects where object_id = p_clipboard_id and object_type = ''clipboard'') then 
        delete from acs_permissions
            where object_id = p_clipboard_id;

        delete from clipboards
            where clipboard_id = p_clipboard_id;

        PERFORM acs_object__delete(p_clipboard_id);

        return 0;
    else
        raise NOTICE ''clipboard__delete object_id % does not exist or is not a clipboard'',p_clipboard_id;
        return 0;
    end if;
end;' language 'plpgsql';

select define_function_args('clipboard__delete','clipboard_id');

create or replace function clipboard__title (integer)
returns varchar as '
declare
    p_clipboard_id        alias for $1;
    v_title           varchar;
begin
    SELECT title into v_title
      FROM acs_objects
     WHERE object_id = p_clipboard_id 
       and object_type = ''clipboard'';

    return v_title;
end;
' language 'plpgsql';

select define_function_args('clipboard__title','clipboard_id');
