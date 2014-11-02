fs = require 'fs'
path = require 'path'

find_test_file = (active_path) ->
  test_dir = path.dirname(active_path.replace(/^lib/, 'spec'))
  [_, file_name_prefix, file_name_suffix] = path.basename(active_path).match(/^(.+)\.(\w+)$/)
  for project_root in atom.project.getPaths()
    test_files = fs.readdirSync(path.join(project_root, test_dir))
    matches = test_files.filter (file_name) ->
      if file_name.indexOf(file_name_prefix) == 0 && file_name.indexOf(file_name_suffix) == file_name.length - file_name_suffix.length
        middle = file_name.substring(file_name_prefix.length, file_name.length - file_name_suffix.length - 1)
        return middle == '_spec' || middle == '-spec'
    return path.join(project_root, test_dir, matches[0])

find_implementation_file = (active_path) ->
  implementation_dir = path.dirname(active_path.replace(/^spec/, 'lib'))
  implementation_file_name = path.basename(active_path).replace(/[-_]spec(\.\w+)$/, '$1')
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
      path_finder = find_test_file
    else
      path_finder = find_implementation_file

    if (new_path = path_finder(active_path))
      atom.workspace.open(new_path)
