<master>
  <property name="title">Your clipboards</property>
  <property name="context">clipboards</property>
  <if @user_id@ eq 0> 
    You need to <a href="/register/">log in or register</a> to manage you clipboards.
  </if>
  <else>
    <if @clipboards:rowcount@ eq 0>
      You do not currently have any clipboards.
    </if>
    <else> 
      <ul>
        <multiple name="clipboards">
          <li> 
            <a href="view?clipboard_id=@clipboards.clipboard_id@">@clipboards.title@</a> <if @clipboards.clipped@ ne 0>(@clipboards.clipped@ items, last used @clipboards.last_clip@)</if>
            <a class="button" href="ae?clipboard_id=@clipboards.clipboard_id@">edit</a> <a href="delete?clipboard_id=@clipboards.clipboard_id@" class="button">delete</a>
          </li>
        </multiple>
      </ul>
    </else>
  </else>
