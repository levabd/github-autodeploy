class Dashing.Playmarket extends Dashing.Widget
  ready: ->
    @onData(this)
 
  onData: (data) ->
    widget = $(@node)
    app = @get('app')
    rating = app.averageRating
    voters_count = app.votersCount
    widget.find('.google-rating-value').html( '<div>Рейтинг</div><span id="google-rating-integer-value">' + rating + '</span>')
    widget.find('.google-voters-count').html( '<span id="google-voters-count-value">' + voters_count + '</span> отзывов' )
   
