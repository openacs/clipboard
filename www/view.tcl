# /packages/cop-ui/www/clipboard/view.tcl
ad_page_contract {
    display a given clipboards contents.

    @author Jeff Davis (davis@xarg.net)
    @creation-date 11/12/2003
    @cvs-id $Id$
} { 
    clipboard_id:integer,notnull
}

set user_id [auth::refresh_login]

# Check that the user is permissioned for this clipboard.
permission::require_permission -party_id $user_id -object_id $clipboard_id -privilege read

if {![db_0or1row clipboard {
    SELECT u.first_names || ' ' || u.last_name as owner_name, c.owner_id, o.title 
      FROM clipboards c, acs_objects o, acs_users_all u
     WHERE c.clipboard_id = :clipboard_id 
       and o.object_id = c.clipboard_id
       and o.object_type = 'clipboard'
       and c.owner_id = u.user_id}] } {
    ad_return_complaint 1 "Invalid clipboard id."
    ad_script_abort
}

set context [list [list ./ Clipboards] $title]

# TODO: Yuck! should fix this query.  maybe stick it in an object_type view which restricts to clipable things.
db_multirow -extend {clipped} items get_items {
    SELECT o.object_id, t.pretty_name as object_type, coalesce(o.title,'object '||o.object_id) as item_title, to_char(m.clipped_on,'YYYY-MM-DD HH24:MI:SS') as clipped_ansi
      FROM clipboard_object_map m, acs_objects o, acs_object_types t
     WHERE clipboard_id = :clipboard_id
       and o.object_id = m.object_id
       and t.object_type = (case when o.object_type = 'content_item' then (select case when i.content_type = 'content_extlink' then 'content_extlink' else r.object_type end from acs_objects r, cr_items i where r.object_id = coalesce(i.live_revision, i.latest_revision, i.item_id) and i.item_id = o.object_id) else o.object_type end)
} {
    set clipped [util::age_pretty -timestamp_ansi $clipped_ansi -sysdate_ansi [clock_to_ansi [clock seconds]]]
}

