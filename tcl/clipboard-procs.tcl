# /packages/cop-base/tcl/clipboard-procs.tcl
ad_library {
    TCL library for the COP clipboard

    @author Jeff Davis <davis@xarg.net>

    @creation-date 10/23/2003
    @cvs-id $Id$
}

namespace eval clipboard {}

ad_proc -public clipboard::clipboards {
    -count:boolean
    -create_new:boolean
    -force_default:boolean
    user_id
    datasource
} {
    creates a multirow datasource with the existing clipboards

    @param create_new add a "Create new folder" entry to list
    @param force_default create the datasource with a default folder even if none exist
    @param user_id the owner id for the folders
    @param datasource the datasource name to use.


    @return count of rows found, multirow created at adp_level

    @author Jeff Davis davis@xarg.net
    @creation-date 2003-10-30
} {
    if {!$count_p} { 
        db_multirow $datasource clipboards {
            SELECT c.clipboard_id, o.title, 0 as selected, 0 as clipped
              FROM acs_objects o, clipboards c 
             WHERE c.owner_id = :user_id 
               and o.object_id = c.clipboard_id
        }
    } else { 
        db_multirow $datasource clipboards_count {
            SELECT c.clipboard_id, o.title, 0 as selected, coalesce(n.clipped,0) as clipped, to_char(last_clip,'YYYY-MM-DD HH24:MI:SS') as last_clip
              FROM acs_objects o, clipboards c left join (select clipboard_id, count(*) as clipped, max(clipped_on) as last_clip from clipboard_object_map where clipboard_id in (select clipboard_id from clipboards where owner_id = :user_id) group by clipboard_id) n on n.clipboard_id = c.clipboard_id
             WHERE c.owner_id = :user_id 
               and o.object_id = c.clipboard_id
        } { 
            set last_clip [util::age_pretty -timestamp_ansi $last_clip -sysdate_ansi [clock_to_ansi [clock seconds]]]
        }
    }

    if {[template::multirow size $datasource] > 0} {
        if {$create_new_p} {
            template::multirow append $datasource -1 "New clipboard" 0
        }
    } else {
        if { $force_default_p } {
            template::multirow create $datasource clipboard_id title selected
            template::multirow append $datasource 0 "General" 0
        }
    }
    return [template::multirow size $datasource]
}


ad_proc -public clipboard::clipped {
    object_id
    user_id
    datasource
} {
    creates a multirow with the list of clipboards to which you 
    have attached an object.

    @param user_id the owner id to check for.
    @param object_id the object which is clipped.
    @param datasource the datasource name to use.

    @return count of rows found, multirow created at adp_level

    @author Jeff Davis davis@xarg.net
    @creation-date 2003-10-30
} {
    db_multirow $datasource clipped {
	select c.clipboard_id, o.title 
	 from clipboards c, clipboard_object_map m, acs_objects o
	 where m.object_id = :object_id 
	   and m.clipboard_id = c.clipboard_id 
           and o.object_id = m.clipboard_id
	   and owner_id = :user_id
	 order by lower(o.title)
    }

    return [template::multirow size $datasource]
}


ad_proc -public clipboard::new {
    -clipboard_id
    -owner_id
    -title:required
    -package_id
    -creation_user_id
    -peeraddr
    -context
} {
    create a new clipboard.
} {
    if {![exists_and_not_null clipboard_id]} {
        set clipboard_id [db_nextval acs_object_id_seq]
    }

    # should check for connected and if not fill in sensible 
    # stuff and barf on absence of owner_id.

    if {![exists_and_not_null owner_id]} {
        set owner_id [ad_conn user_id]
    }
    if {![exists_and_not_null peeraddr]} {
        set peeraddr [ad_conn peeraddr]
    }
    if {![exists_and_not_null context]} {
        set context [ad_conn package_id]
    }
    if {![exists_and_not_null package_id]} {
        set package_id [ad_conn package_id]
    }
    if {![exists_and_not_null creation_user_id]} {
        set creation_user_id [ad_conn user_id]
    }

    db_exec_plsql new_clipboard {*SQL*}
}

ad_proc -public clipboard::delete {
    -clipboard_id
} {
    create a new clipboard.
} {
    db_exec_plsql delete_clipboard {*SQL*}
}




ad_proc -public clipboard::attach {
    -clipboard_id:required
    -object_id:required
    -user_id:required
} {
    attach an item to a clipboard
} {
    if {[catch {db_dml map_object {}} errMsg]} { 
        # Check if it was a pk violation (i.e. already inserted)
        if {![string match "*clipboard_object_map_pk*" $errMsg]} { 
            ad_return_error "Clipboard Insert error" "Error putting object into clipboard (query name map_object)<pre>$errMsg</pre>"
            ad_script_abort
        }
    }
}

ad_proc -public clipboard::remove {
    -clipboard_id:required
    -object_id:required
    -user_id:required
} {
    remove item from a clipboard
} {
    db_dml unmap_object {}
}