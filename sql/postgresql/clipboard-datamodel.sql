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

create table clipboards ( 
    clipboard_id      integer 
                      constraint clipboards_clipbd_id_fk
                      references acs_objects(object_id)
                      constraint clipboards_pk
                      primary key,
    owner_id          integer
                      constraint clipboards_owner_id_fk
                      references parties(party_id) on delete cascade
                      constraint clipboards_owner_id_nn
                      not null
);

comment on table clipboards is '
 Table for saving a collection of object_ids.  created as an acs_object
 so it can be permissioned and categorized.
';

create table clipboard_object_map (
   clipboard_id       integer
                      constraint clipboards_fk
                      references clipboards(clipboard_id) on delete cascade, 
   object_id          integer 
                      constraint clipboard_acs_objects_fk
                      references acs_objects(object_id) on delete cascade,
   clipped_on         timestamptz,
   constraint clipboard_object_map_pk 
   primary key (clipboard_id, object_id)
);

comment on table clipboard_object_map is '
   Map stores which objects have been saved to a given clipboard.
';


select acs_object_type__create_type(
        'clipboard',
        'Clipboard',
        'Clipboards',
        'acs_object',
        'clipboards',
        'clipboard_id',
        'clipboard',
        'f',
        'clipboard__title',
        null
);



