{WorkspaceView} = require 'atom'

temp = require 'temp'
fs = require 'fs'

require '../lib/go-to-test'

temp.track()

describe 'go-to-test', ->
  tmp_dir = null

  set_up_ruby_project = ->
    fs.mkdirSync(tmp_dir + '/lib')
    fs.mkdirSync(tmp_dir + '/lib/foo')
    fs.mkdirSync(tmp_dir + '/spec')
    fs.mkdirSync(tmp_dir + '/spec/foo')
    fs.writeFileSync(tmp_dir + '/lib/file_one.rb', '')
    fs.writeFileSync(tmp_dir + '/lib/foo/file_two.rb', '')
    fs.writeFileSync(tmp_dir + '/spec/foo/file_two_spec.rb', '')

  set_up_coffee_script_project = ->
    fs.mkdirSync(tmp_dir + '/lib')
    fs.mkdirSync(tmp_dir + '/lib/foo')
    fs.mkdirSync(tmp_dir + '/spec')
    fs.mkdirSync(tmp_dir + '/spec/foo')
    fs.writeFileSync(tmp_dir + '/lib/file_one.rb', '')
    fs.writeFileSync(tmp_dir + '/lib/foo/file-two.coffee', '')
    fs.writeFileSync(tmp_dir + '/spec/foo/file-two-spec.coffee', '')

  trigger_toggle = ->
    editor = atom.workspace.getActiveTextEditor()
    atom.commands.dispatch(atom.views.getView(editor), 'go-to-test:toggle')

  trigger_and_wait_for_change = (block) ->
    new_path = null

    atom.workspace.onDidOpen (e) ->
      new_path = e.uri.replace(/^\/private/, '')

    trigger_toggle()

    waitsFor ->
      new_path

    runs ->
      block(new_path)

  it_moves_from_implementation_to_test_and_back_again = (implementation_path, test_path) ->
    describe 'when a non-test file is active', ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(tmp_dir + implementation_path)

      it 'opens the test file', ->
        trigger_and_wait_for_change (new_path) ->
          expect(new_path).toEqual(tmp_dir + test_path)

    describe 'when a test file is active', ->
      beforeEach ->
        waitsForPromise ->
          atom.workspace.open(tmp_dir + test_path)

      it 'opens the non-test file', ->
        trigger_and_wait_for_change (new_path) ->
          expect(new_path).toEqual(tmp_dir + implementation_path)

  beforeEach ->
    tmp_dir = null
    atom.workspaceView = new WorkspaceView

    temp.mkdir 'go-to-test', (err, path) ->
      tmp_dir = path

    waitsFor ->
      tmp_dir

    runs ->
      atom.project.setPaths([tmp_dir])
      atom.packages.activatePackage('go-to-test')

  describe 'when the go-to-test:toggle event is triggered', ->
    describe 'in a Ruby project', ->
      beforeEach ->
        set_up_ruby_project()

      it_moves_from_implementation_to_test_and_back_again '/lib/foo/file_two.rb', '/spec/foo/file_two_spec.rb'

    describe 'in a CoffeeScript project', ->
      beforeEach ->
        set_up_coffee_script_project()

      it_moves_from_implementation_to_test_and_back_again '/lib/foo/file-two.coffee', '/spec/foo/file-two-spec.coffee'
