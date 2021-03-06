# frozen_string_literal: true

require 'rainbow'
require 'rexml/document'

require_relative '../project'
require_relative '../lang/lang_factory'
require_relative 'table'
require_relative 'data_field'

# Store Concept information
class Concept
  attr_reader :id, :lang, :context
  attr_reader :names, :type, :filename
  attr_reader :data
  attr_accessor :process

  @@id = 0

  def initialize(xml_data, filename, lang_code = 'en', context = [])
    @@id += 1
    @id = @@id

    @filename = filename
    @process = false
    @lang = LangFactory.instance.get(lang_code)

    if context.class == Array
      @context = context
    elsif context.nil?
      @context = []
    else
      @context = context.split(',')
      @context.collect!(&:strip)
    end
    @names = ['concept.' + @id.to_s]
    @type  = 'text'

    @data = {}
    @data[:tags] = []
    @data[:texts] = []
    @data[:images] = []         # TODO: By now, We'll treat images separated from texts
    @data[:textfile_paths] = [] # TODO: By now, We'll treat this separated from texts
    @data[:tables] = []
    @data[:neighbors] = []
    @data[:reference_to] = []
    @data[:referenced_by] = []

	  read_data_from_xml(xml_data)
  end

  def name(option = :raw)
    DataField.new(@names[0], @id, @type).get(option)
  end

  def text
    @data[:texts][0] || '...'
  end

  def process?
    @process
  end

  def try_adding_neighbor(other)
    p = calculate_nearness_to_concept(other)
    return if p.zero?

    @data[:neighbors] << { concept: other, value: p }
    # Sort neighbors list
    @data[:neighbors].sort! { |a, b| a[:value] <=> b[:value] }
    @data[:neighbors].reverse!
  end

  def calculate_nearness_to_concept(other)
    weights = Project.instance.formula_weights

    li_max1 = @context.count
    li_max2 = @data[:tags].count
    li_max3 = @data[:tables].count

    lf_alike1 = lf_alike2 = lf_alike3 = 0.0

    # check if exists this items from concept1 into concept2
    @context.each { |i| lf_alike1 += 1.0 unless other.context.index(i).nil? }
    @data[:tags].each { |i| lf_alike2 += 1.0 unless other.tags.index(i).nil? }
    @data[:tables].each { |i| lf_alike3 += 1.0 unless other.tables.index(i).nil? }

    lf_alike = (lf_alike1 * weights[0] + lf_alike2 * weights[1] + lf_alike3 * weights[2])
    li_max = (li_max1 * weights[0] + li_max2 * weights[1] + li_max3 * weights[2])
    (lf_alike * 100.0 / li_max)
  end

  def try_adding_references(other)
    reference_to = 0
    @data[:tags].each { |i| reference_to += 1 unless other.names.index(i.downcase).nil? }
    @data[:texts].each do |t|
      text = t.clone
      text.split(' ').each do |word|
        reference_to += 1 unless other.names.index(word.downcase).nil?
      end
    end
    if reference_to.positive?
      @data[:reference_to] << other.name
      other.data[:referenced_by] << name
    end
  end

  def method_missing(method)
    @data[method]
  end

  private

  def read_data_from_xml(xml_data)
    xml_data.elements.each do |i|
      case i.name
      when 'names'
        process_names(i)
      when 'tags'
        process_tags(i)
      when 'context'
        # DEPRECATED: Don't use xml tag <context>
        # instead define it as attibute of root xml tag
        process_context(i)
      when 'text'
        # DEPRECATED: Use xml tag <def> instead of <text>
        process_text(i)
      when 'def'
        process_def(i)
      when 'table'
        @data[:tables] << Table.new(self, i)
      else
        text = "   [ERROR] <#{i.name}> unkown XML attribute for concept #{name}"
        msg = Rainbow(text).color(:red)
        Project.instance.verbose msg
      end
    end
  end

  def process_names(value)
    @names = []
    j = value.text.split(',')
    j.each { |k| @names << k.strip }
    @type = value.attributes['type'].strip if value.attributes['type']
  end

  def process_tags(value)
    raise '[Error] tags label empty!' if value.text.nil? || value.text.size.zero?
    @data[:tags] = value.text.split(',')
    @data[:tags].collect!(&:strip)
  end

  def process_context(value)
    msg = '   │  ' + Rainbow(' [DEPRECATED] Concept ').yellow
    msg += Rainbow(name).yellow.bright
    msg += Rainbow(' move <context> tag info to <map>.').yellow
    Project.instance.verbose msg
    @context = value.text.split(',')
    @context.collect!(&:strip)
  end

  def process_text(value)
    msg = '   │  ' + Rainbow(' [DEPRECATED] Concept ').yellow
    msg += Rainbow(name).yellow.bright
    msg += Rainbow(' replace <text> tag by <def>.').yellow
    Project.instance.verbose msg
    @data[:texts] << value.text.strip
  end

  def process_def(value)
    case value.attributes['type']
    when 'image'
      msg = "[DEBUG] Concept#read_xml: image #{Rainbow(value.text).bright}"
      Project.instance.verbose Rainbow(msg).yellow
    when 'image_url'
      @data[:images] << value.text.strip
    when 'textfile_path'
      @data[:textfile_paths] << value.text.strip
    else
      @data[:texts] << value.text.strip
    end
  end
end
