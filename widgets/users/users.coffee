class Dashing.Users extends Dashing.Widget
  ready: ->
    @onData(this)
 
  onData: (data) ->
    widget = $(@node)
    users = @get('users')
    android_users = users.androidUsersCount
    ios_users = users.iosUsersCount
    total_users = android_users + ios_users
    android_percent = (android_users * 100 - (android_users * 100) % total_users) / total_users
    ios_percent = (ios_users * 100 - (ios_users * 100) % total_users) / total_users
    widget.find('.total-users').html( '<div>ЗА ВСЕ ВРЕМЯ. Даже тех кто установил и удалил</div><span id="total-users-integer-value">' + total_users + '</span>')
    widget.find('.android-users').html( "Android: <span id='android-users-value'> #{android_users} (#{android_percent % total_users}%)</span>" )
    widget.find('.ios-users').html('iOS: <span id="ios-users-value">' + ios_users + ' (' + ios_percent + '%)</span>' )
   
