class ThetaViewer
  constructor: (jQueryPath) ->
    if typeof jQueryPath is 'string'
      @dom = $(jQueryPath)
    else
      @dom = jQueryPath
    @__defineGetter__ 'width', ->
      return @dom.width()
    @__defineGetter__ 'height', ->
      return @dom.height()
    @images = []
    @interval = 1000
    @materialOffset = 0
    @camera = new THREE.PerspectiveCamera 100, @width/@height
    @camera.position.set 0, 0, 180
    @scene = new THREE.Scene
    @renderer = new THREE.WebGLRenderer
    @renderer.setSize @width, @height
    @dom[0].appendChild @renderer.domElement

    @controls = new THREE.OrbitControls @camera

    @controls.addEventListener 'change', =>
      @renderer.render @scene, @camera

    @sphere = new THREE.SphereGeometry 300, 100, 100
    @mesh = new THREE.Mesh @sphere
    @mesh.scale.x = -1
    @scene.add @mesh

    @autoRotate = false

    _oldWidth = @width
    _oldHeight = @height
    setInterval =>
      if _oldWidth isnt @width or _oldHeight isnt @height
        _oldWidth = @width
        _oldHeight = @height
        @renderer.setSize @width, @height
    , 100

  load: (callback = ->) ->
    @loadMaterials =>
      console.log "loaded materials"
      @displayNextMaterial()
      setInterval =>
        @displayNextMaterial()
      , @interval

      autoRotate = =>
        @controls.rotateLeft 0.003
        @controls.update()
      setInterval =>
        autoRotate() if @autoRotate
      , 50

  loadMaterials: (callback) ->
    mapping = new THREE.UVMapping
    async.map @images, (img, async_done) ->
      console.log img
      texture = THREE.ImageUtils.loadTexture img, mapping, ->
        material = new THREE.MeshBasicMaterial(map: texture)
        async_done null, material
    , (err, results) =>
      @materials = results
      callback()

  displayNextMaterial: ->
    @materialOffset += 1
    @materialOffset = 0 unless @materialOffset < @materials.length
    @mesh.material = @materials[@materialOffset]
    @renderer.render @scene, @camera

if module?.exports?
  module.exports = ThetaViewer
else
  window.ThetaViewer = ThetaViewer
