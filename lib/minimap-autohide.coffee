{CompositeDisposable} = require 'event-kit'

module.exports =
  active: false

  isActive: -> @active

  activate: (state) ->
    @subscriptions = new CompositeDisposable

  consumeMinimapServiceV1: (@minimap) ->
    @minimap.registerPlugin 'minimap-autohide', this

  deactivate: ->
    @minimap.unregisterPlugin 'minimap-autohide'
    @minimap = null

  activatePlugin: ->
    return if @active

    @active = true

    @minimapsSubscription = @minimap.observeMinimaps (minimap) =>
      minimapElement = atom.views.getView(minimap)
      editor= minimap.getTextEditor()
      @subscriptions.add editor.onDidChangeScrollTop =>
        @handleScroll minimapElement

  handleScroll: (el)->
    el.classList.add('scrolling')

    if el.timer
      clearTimeout el.timer

    el.timer = setTimeout ( ->
      el.classList.remove('scrolling')
    ), 1500

  deactivatePlugin: ->
    return unless @active

    @active = false
    @minimapsSubscription.dispose()
    @subscriptions.dispose()
