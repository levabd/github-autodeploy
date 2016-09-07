class Dashing.UsersGraph extends Dashing.Chartjs
  ready: ->
    @onData(this)
 
  onData: (data) ->
    widget = $(@node)
    labels = @get('labels')
    points = @get('points')
    @lineChart 'myChart', # The ID of your html element
      labels, # Horizontal labels
      [
        label: 'Number of pushups' # Text displayed when hovered
        colorName: 'blue' # Color of data
        data: points # Vertical points
      ]
   
