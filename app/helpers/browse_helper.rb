module BrowseHelper
  def subpaths_to path, &block
    path.split('/').reject(&:blank?).inject("") do |path, component|
      path << "/" unless path.blank?
      path << component
      yield component, path
      path
    end
  end
end
