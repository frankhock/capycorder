class RecorderUI

  $ui: null

  delayToHide: 5
  hideAfter: null

  getTemplate: ->
    """
      <div id="capycorder">
        <form action="#" method="POST" class="prompt-name">
          <div class="capycorder-label">
            <img src="#{@chrome.extension.getURL('images/button_off.png')}" />
            Name your test. It
          </div>
          <div class="capycorder-input-wrapper">
            <input type="text" id="capycorder-spec-name" placeholder="should do something" />
          </div>
          <div class="capycorder-actions">
            <a href="#" class="cancel">Cancel</a>
            <button type="submit">OK</button>
          </div>
        </form>
        <div class="capture-actions">
          <div>
            <img src="#{@chrome.extension.getURL('images/button_capture_actions.png')}" />
            Interact with the page to record actions.
          </div>
        </div>
        <div class="capture-matchers">
          <div>
            <img src="#{@chrome.extension.getURL('images/button_capture_matchers.png')}" />
            Select text ranges or elements to record matchers.
          </div>
       </div>
        <div class="generate">
          <div>
            <img src="#{@chrome.extension.getURL('images/button_generate.png')}" />
            Thanks! The recorded spec has been copied to the clipboard.
          </div>
        </div>
      </div>
    """

  constructor: (options) ->
    @chrome = options.chrome
    @create()

  _created: false
  create: ->
    if !@_created && window.top == window.self
      @$ui = $(@getTemplate())
      @$ui.appendTo('body').find('> div, > form').hide()
      @_created = true

  showNamePrompt: (block = ->) ->
    @_hideVisible =>
      $visible = @$ui.find('.prompt-name').show()
      @_showUI =>
        @$ui.find('.prompt-name input').trigger('focus')
      $visible
        .find('input')
        .val('')
        .end()
        .find('a')
        .one 'click', =>
          @_hideVisible()
          block(null)
        .end()
        .one 'submit', (e) =>
          e.preventDefault()
          name = $visible.find('#capycorder-spec-name').val()
          @_hideVisible()
          block(name)

  show: (state) ->
    @_hideVisible =>
      selector = ".#{state.replace('.', '-')}"
      @$ui.find(selector).show()
      @_showUI()
      @$ui.one 'mouseover.recorderui', => @_hideVisible()
      @hideAfter = setTimeout @_hideVisible, @delayToHide * 1000

  _showUI: (block = ->) ->
    @$ui.animate marginTop: '0px', 250, => block()

  _hideUI: (block = ->) ->
    @$ui.animate marginTop: '-200px', 250, => block()

  _hideVisible: (block = ->) =>
    clearTimeout @hideAfter if @hideAfter?
    @$ui.off 'mouseover.recorderui'
    $visible = @$ui.find('div:visible, form:visible')
    if $visible.length
      @_hideUI =>
        $visible.hide()
        block()
     else
       block()


window.RecorderUI = RecorderUI
