-- Simple object clipboard datamodel
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

create or replace function tmp_clip_delete ()
returns integer as '
declare
  coll_rec RECORD;
begin
  for coll_rec in select object_id
      from acs_objects
      where object_type = ''clipboard''
    loop
      PERFORM acs_object__delete (coll_rec.object_id);
    end loop;

    return 1;
end; ' language 'plpgsql';

select tmp_clip_delete ();
drop function tmp_clip_delete ();

select acs_object_type__drop_type('clipboard', 'f');
drop table clipboard_object_map;
drop table clipboards;

select drop_package('clipboard');
