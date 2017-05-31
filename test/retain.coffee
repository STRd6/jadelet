describe "retain", ->
  it "should keep elements bound even when reused in the DOM", ->
    CanvasTemplate = makeTemplate """
      canvas(@width @height)
    """

    EditorTemplate = makeTemplate """
      editor
        = @title
        = @canvas
    """

    canvasModel =
      width: Observable 64
      height: Observable 64

    canvasElement = CanvasTemplate canvasModel
    Jadelet.retain canvasElement

    editorModel =
      title: Observable "yo"
      canvas: canvasElement

    editorElement = EditorTemplate editorModel

    assert.equal canvasElement.getAttribute('height'), 64

    canvasModel.height 48
    assert.equal canvasElement.getAttribute('height'), 48

    editorModel.title "lo"

    canvasModel.height 32
    assert.equal canvasElement.getAttribute('height'), 32

    Jadelet.release canvasElement
