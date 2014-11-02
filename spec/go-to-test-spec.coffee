{WorkspaceView} = require 'atom'

temp = require 'temp'
fs = require 'fs'

require '../lib/go-to-test'

temp.track()

describe 'go-to-test', ->
  activationPromise = null
  editor = null
  editorView = null
  tmp_dir = null

  set_up_project = ->
    fs.mkdirSync(tmp_dir + '/lib')
    fs.mkdirSync(tmp_dir + '/lib/foo')
    fs.mkdirSync(tmp_dir + '/spec')
    fs.mkdirSync(tmp_dir + '/spec/foo')
    fs.writeFileSync(tmp_dir + '/lib/file_one.rb', '')
    fs.writeFileSync(tmp_dir + '/lib/foo/file_two.rb', '')
    fs.writeFileSync(tmp_dir + '/spec/foo/file_two_spec.rb', '')

  trigger_toggle = ->
    atom.workspaceView.getActiveView().trigger 'go-to-test:toggle'

  trigger_and_wait_for_change = (block) ->
    new_path = null

    waitsForPromise ->
      activationPromise

    atom.workspace.onDidOpen (e) ->
      new_path = e.uri.replace(/^\/private/, '')

    trigger_toggle()

    waitsFor ->
      new_path

    runs ->
      block(new_path)

  beforeEach ->
    tmp_dir = null
    atom.workspaceView = new WorkspaceView

    temp.mkdir 'go-to-test', (err, path) ->
      tmp_dir = path

    waitsFor ->
      tmp_dir

    runs ->
      atom.project.setPaths([tmp_dir])
      activationPromise = atom.packages.activatePackage('go-to-test')

  describe 'when the go-to-test:toggle event is triggered', ->
    beforeEach ->
      set_up_project()

    describe 'when a non-test file is active', ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(tmp_dir + '/lib/foo/file_two.rb')

      it 'opens the test file', ->
        trigger_and_wait_for_change (new_path) ->
          expect(new_path).toEqual(tmp_dir + '/spec/foo/file_two_spec.rb')

    describe 'when a test file is active', ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(tmp_dir + '/spec/foo/file_two_spec.rb')

      it 'opens the non-test file', ->
        trigger_and_wait_for_change (new_path) ->
          expect(new_path).toEqual(tmp_dir + '/lib/foo/file_two.rb')
