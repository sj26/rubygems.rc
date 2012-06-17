# Let us introspect tar entries for their (programming) language
class Gem::Package::TarReader::Entry
  include Linguist::BlobHelper

  delegate :name, :size, to: :header

  def data
    # XXX This is awful, but it works.
    # We can optimise this into better data structures in GemFile later.
    @data ||= read
  end
end
