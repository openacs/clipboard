  <master>
  <property name="title">@title@</property>
  <property name="context">@context@</property>


  <p>Clipboard @title@ (@items:rowcount@ items attached) <a href="ae?clipboard_id=@clipboard_id@" class="button">Edit title</a> 
  <a href="." class="button">All clipboards</a></p>
  <if @items:rowcount@ gt 0>
    <p>Items in this clipboard:</p>
    <ul>
      <multiple name="items">
        <li style="padding: 4px;"> <a href="/o/@items.object_id@">@items.item_title@</a> [@items.object_type@], clipped @items.clipped@ <a href="remove?clipboard_id=@clipboard_id@&amp;object_id=@items.object_id@" class="button">remove</a></li>
      </multiple>
    </ul>
  </if>
  <else>
    <p>There are no items in this clipboard.</p>
  </else>


<p><a href="delete?clipboard_id=@clipboard_id@" class="button">Delete this clipboard</a></p>

