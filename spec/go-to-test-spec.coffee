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
    temp.mkdir 'go-to-test', (err, path) ->
      fs.mkdirSync(path + '/lib')
      fs.mkdirSync(path + '/lib/foo')
      fs.mkdirSync(path + '/spec')
      fs.mkdirSync(path + '/spec/foo')
      fs.writeFileSync(path + '/lib/file_one.rb', '')
      fs.writeFileSync(path + '/lib/foo/file_two.rb', '')
      fs.writeFileSync(path + '/spec/foo/file_two_spec.rb', '')
      tmp_dir = path

  trigger_toggle = ->
    atom.workspaceView.getActiveView().trigger 'go-to-test:toggle'

  beforeEach ->
    tmp_dir = null
    atom.workspaceView = new WorkspaceView

    set_up_project()

    waitsFor ->
      tmp_dir

    runs ->
      atom.project.setPaths([tmp_dir])
      activationPromise = atom.packages.activatePackage('go-to-test')

  describe 'when the go-to-test:toggle event is triggered', ->
    describe 'when a non-test file is active', ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(tmp_dir + '/lib/foo/file_two.rb')

      it 'opens the test file', ->
        new_path = null

        waitsForPromise ->
          activationPromise

        atom.workspace.onDidOpen (e) ->
          new_path = e.uri.replace(/^\/private/, '')

        trigger_toggle()

        waitsFor ->
          new_path

        runs ->
          expect(new_path).toEqual(tmp_dir + '/spec/foo/file_two_spec.rb')

    describe 'when a test file is active', ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(tmp_dir + '/spec/foo/file_two_spec.rb')

      it 'opens the non-test file', ->
        new_path = null

        waitsForPromise ->
          activationPromise

        atom.workspace.onDidOpen (e) ->
          new_path = e.uri.replace(/^\/private/, '')

        trigger_toggle()

        waitsFor ->
          new_path

        runs ->
          expect(new_path).toEqual(tmp_dir + '/lib/foo/file_two.rb')

