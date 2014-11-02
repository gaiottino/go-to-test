fs = require 'fs'
path = require 'path'

find_test_file = (active_path) ->
  test_dir = path.dirname(active_path.replace(/^lib/, 'spec'))
  test_file_name = path.basename(active_path).replace(/(\.\w+)$/, '_spec$1')
  for project_root in atom.project.getPaths()
    full_path = path.join(project_root, test_dir, test_file_name)
    if fs.existsSync(full_path)
      return full_path

find_implementation_file = (active_path) ->
  implementation_dir = path.dirname(active_path.replace(/^spec/, 'lib'))
  implementation_file_name = path.basename(active_path).replace(/_spec(\.\w+)$/, '$1')
  for project_root in atom.project.getPaths()
    full_path = path.join(project_root, implementation_dir, implementation_file_name)
    if fs.existsSync(full_path)
      return full_path

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'go-to-test:toggle', '.editor', @toggle

  toggle: (e) ->
    editor = atom.workspace.getActiveTextEditor()
    active_path = atom.project.relativize(editor.getPath())
    if active_path.indexOf('lib/') == 0
      if (test_path = find_test_file(active_path))
        atom.workspace.open(test_path)
    else if active_path.indexOf('spec/') == 0
      if (implementation_path = find_implementation_file(active_path))
        atom.workspace.open(implementation_path)
