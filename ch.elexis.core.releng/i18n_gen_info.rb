#!/usr/bin/env ruby
# Copyright 2017 by Niklaus Giger <niklaus.giger@member.fsf.org>
#
# TODO: Use google-translate
# https://github.com/GoogleCloudPlatform/ruby-docs-samples/tree/master/translate
#   * Need https://developers.google.com/accounts/docs/application-default-credentials
#   * gem install googleauth
#   * gem install google-api-client
# require 'google/apis/translate_v2'
# translate = Google::Apis::TranslateV2::TranslateService.new
# translate.key = 'YOUR_API_KEY_HERE'
# result = translate.list_translations('Hello world!', 'es', source: 'en')
# puts result.translations.first.translated_text
# to connect to the database
# sudo apt-get install sqlite3 unixodbc unixodbc-bin libreoffice-base-drivers
# /etc/odbcinst.ini aufgefüllt gemäss https://wiki.openoffice.org/wiki/Documentation/How_Tos/Using_SQLite_With_OpenOffice.org#SQLite_ODBC_Driver
#
require 'google/apis/translate_v2'
require "rexml/document"
include REXML  # so that we don't have to prefix everything with REXML::...
require 'ostruct'
require 'pp'
require 'uri'
require 'pry-byebug'
require 'csv'
require 'net/http'
require 'json'
require 'sequel'
require 'sqlite3'
require 'trollop'
require 'logger'
$stdout.sync = true
Sqlite3File = File.join(Dir.home, 'elexis-translation.db')

class GoogleTranslation
  @@updated_cache = false
  CacheFileCSV = File.join(Dir.home, 'google_translation_cache.csv')
  BaseLanguageURL='https://translate.googleapis.com/translate_a/single?client=gtx&sl='
  Translate = Google::Apis::TranslateV2::TranslateService.new
  Translate.key = ENV['TRANSLATE_API_KEY']
    # url = "#{BaseLanguageURL}#{source_language}&format=json&tl=#{target_language}&dt=t&q=#{URI.encode(what)}"
    # uri = URI(url)
    # response = Net::HTTP.get(uri)
    # JSON.parse(response)

  def self.translationCache
  	@@translationCache
  end
  def self.translate_text(what, target_language='it', source_language='de')
    key = [what, target_language, source_language]
    unless @@translationCache[key]
      begin
        value = Translate.list_translations(what, target_language, source: source_language)
        @@translationCache[key] = value.translations.collect{|x| x.translated_text}
        puts "Added #{key} #{@@translationCache[key]}"
        @@updated_cache = true
      rescue => error
        puts error
        puts "translate_text failed. Is environment variable TRANSLATE_API_KEY not specified?"
        binding.pry
        exit
      end
    end
    value = @@translationCache[key]
    value = value.first if value.is_a?(Array)
  end

  def self.load_cache
    @@translationCache = {}
    if File.exist?(CacheFileCSV)
      CSV.foreach(CacheFileCSV, :force_quotes => true) do |cells|
        next if cells[0].eql?('src')
        key = [cells[0], cells[1], cells[2]]
        value = cells[3] ? cells[3].chomp : ''
        @@translationCache[key] = [value]
      end
    end
  end

  def self.save_cache
    return unless @@updated_cache
    puts "Saving #{@@translationCache.size} entries to #{CacheFileCSV}"
    CSV.open(CacheFileCSV, "wb", :force_quotes => true) do |csv|
      csv << ['src', 'dst', 'what', 'translated']
      @@translationCache.each do |key, value|
        csv << [key[0],
                key[1],
                key[2],
                value].flatten
      end
    end
  end
  # Initialization
  GoogleTranslation.load_cache
  at_exit do GoogleTranslation.save_cache end
end

class L10N_Cache
  CSV_HEADER_START = ['translation_key']
  CSV_HEADER_SIZE  = L10N_Cache::CSV_HEADER_START.size
  JavaLanguage = 'Java'
  LanguageViews = { 'de' => 'german',
            'fr' => 'french',
            'it' => 'italian',
            'en' => 'english',
            }

  CSV_KEYS = LanguageViews.keys + [JavaLanguage]
  TRANSLATIONS_CSV_NAME = 'translations.csv'
  Translations = Struct.new(:lang, :values)
  REGEX_TRAILING_LANG = /\.plugin$|\.(#{LanguageViews.keys.join('|')})$/

  @@cacheCsvFile = File.join(Dir.home, 'l10n.csv')

  def self.get_translation(key, lang)
    @@l10nCache[key] ? @@l10nCache[key][lang] : ''
  end
  def self.set_translation(key, lang, value)
    @@l10nCache[key] ||= {}
    @@l10nCache[key][lang] = value
  end

  def self.load_cache(cachefile = File.join(Dir.pwd,TRANSLATIONS_CSV_NAME))
    @@cacheCsvFile = cachefile
    @@l10nCache = {}
    if File.exist?(@@cacheCsvFile)
      index = 0
      CSV.foreach(@@cacheCsvFile, :force_quotes => true) do |cells|
        index += 1
        if index == 1
          raise "Unexpected header #{cells.join(',')}" unless cells.eql?(CSV_HEADER_START + CSV_KEYS)
          next
        end
        CSV_KEYS.each_with_index { |lang, index| self.set_translation(cells[0], lang, cells[index+1]) }
      end
    end
  end

  def self.save_cache(csv_file = @@cacheCsvFile)
    puts "Saving #{@@l10nCache.size} entries to #{csv_file}"
    missing_name = csv_file.sub('.csv', '_missing.csv')
    missing = CSV.open(missing_name, "wb:UTF-8", :force_quotes => true)
    missing << (CSV_HEADER_START + CSV_KEYS)
    nr_missing = 0
    CSV.open(csv_file, "wb:UTF-8", :force_quotes => true) do |csv|
      csv <<  (CSV_HEADER_START + CSV_KEYS)
      index = 0
      @@l10nCache.each do |key, info|
        index += 1
        next unless info.is_a?(Hash)
        CSV_KEYS.each{|lang| info[lang] ||= ''}
        info[L10N_Cache::JavaLanguage] = info['en'] if info['en'] && info[L10N_Cache::JavaLanguage].empty?
        info[L10N_Cache::JavaLanguage] = info['de'] if info['de'] && info[L10N_Cache::JavaLanguage].empty?
        translations = []
        CSV_KEYS.each{|lang| translations << info[lang] }
        if translations.uniq.size == 1 && translations.first.eql?('')
          puts "No translation for #{key} present"
          missing << ([key]  + translations).flatten
          nr_missing += 1
        else
          csv << ([key]  + translations).flatten
        end
      end
    end
    puts "Wrote #{nr_missing} entries into #{missing_name}" if nr_missing > 0
  end
  # Initialization
  L10N_Cache.load_cache
end

class I18nInfo
  attr_accessor :main_dir, :start_dir
  @@all_msgs      ||= {}
  @@all_projects  ||= {}
  @@msg_files_read = []
  LanguageViews = { 'de' => 'german',
            'fr' => 'french',
            'it' => 'italian',
            'en' => 'english',
            }

  Translations = Struct.new(:lang, :values)

  def self.all_msgs
    @@all_msgs
  end
  def initialize(directories)
    @@directories = []
    @gen_csv = false
    directories ||= [ ARGV && ARGV[0] ]
    directories.each{ |dir| @@directories << File.expand_path(dir) }
    puts "Initialized for #{@@directories.size} directories"
  end

  def get_git_path(filename)
    `git ls-tree --full-name --name-only HEAD #{filename}`.chomp
  end
  def find_translation  (key, language, project, filename, line_nr)
    found = @@db_texts.where(:key => key.to_s, :language => language, repository: @repository, project: project, filename:  get_git_path(filename), line_nr: line_nr).all.first
    found ? found[:translation] : nil
  end

  EscapeBackslash = /\\([\\]+)/
  LineSplitter = /\s*=\s*/ # ResourceBundleEditor uses ' = ' as separator, other use '='
  #
  # Converts escapces like \u00 to UTF-8 and removes all duplicated backslash.
  # Verifiy it using the following SQL scripts
  # select * from db_texts where translation like '%\u00%';
  # select * from db_texts where translation like '%\\%';
  def convert_to_real_utf(string)
    string = string.gsub(EscapeBackslash, '\\')
    return string unless  /\\u00|/.match(string)
    strings = []
    begin
      string.split('"').each do |part|
        idx = 0
        while idx <= 5 && /\\u00/.match(part)
          part = eval(String.new('"'+part.chomp('\\')+'"'))
          idx += 1
        end
        strings << part
      end
    rescue => error
      puts error
    end
    res = strings.join('"')
    res += '"' if  /"$/.match(string)
    res
  end
  
  # replace_dots_by_underscore is necessary when converting old style uses of Messages.java using the getString method
  def get_key_value(line, replace_dots_by_underscore: true)
    begin
      return false if /^#/.match(line)
      return false if line.length <= 1
      line = line.encode("utf-8", replace: nil)
    rescue => e
      line
    end
    begin
    m = /([^=]*)\s*=\s*(.*)/.match(line.chomp)
    return unless m
    rescue => error
      # Happens with french translat of DataImporter
      line = '%Da' + line[1..-1]
      begin
      m = /([^=]*)\s*=\s*(.*)/.match(line.chomp)
      rescue => error
      	binding.pry
  	   end
    end
    # key has two special thing:
    # * fix some odd occurrences like "BBS_View20\t\t\t "
    # * with Messages.getString(key) it was possible that a key contained a '.', but for as a constant_name we replace it by '_'
    begin
    key = m[1].sub(/\s+$/,'')
    key = key.gsub('.', '_') if replace_dots_by_underscore
    value = m[2].sub(/ \[#{key}\]/,'')
    [key, value]
    rescue => error
      binding.pry
    end
  end

  def analyse_one_message_line(project_name, lang, filename, line_nr, line)
    key, value = get_key_value(line.chomp)
    return unless key
    key = "#{project_name}_#{key}" unless /^messages/i.match(File.basename(filename))
    translation = value ? convert_to_real_utf(value) : ''
    L10N_Cache.set_translation(key, lang, value)
  end
  
  def parse_plug_properties(project_name, lang, propfile)
    return unless File.exist?(propfile)
    File.open(propfile, 'r:ISO-8859-1').readlines.each do |line|
      key, value = get_key_value(line.chomp, replace_dots_by_underscore: false)
      next unless key
      next if /false/.match(key)
      key = "#{project_name}_#{key}"
      L10N_Cache.set_translation(key, lang, value)
    end
  end
  def parse_plugin_xml(project_name, filename)
    return unless File.exist?(filename)
    keys = {}
    IO.readlines(filename).each do |line|
      if (m = /name="%([\.\w]+)/i.match(line.chomp))
        key = [project_name, m[1] ].join('_')
        keys[key] = ''
      end
    end;
    parse_plug_properties(project_name, L10N_Cache::JavaLanguage, filename.sub('.xml', '.properties'))
    LanguageViews.keys.each do |lang|
      propfile = filename.sub('.xml', "_#{lang}.properties")
      next unless File.exist?(propfile)
      parse_plug_properties(project_name, lang, propfile)
    end
    keys
  end

  def analyse_one_message_file(project_name, filename)
    fullname = File.expand_path(filename)
    if @@msg_files_read.index(fullname)
      puts "Skipping #{fullname}"
    else
      @@msg_files_read << fullname
    end
    line_nr = 0
    if m = /_(\w\w)\.properties/.match(File.basename(filename))
      language2 = m[1].to_s
    else
      language2 = L10N_Cache::JavaLanguage
    end
    File.open(filename, 'r:ISO-8859-1').readlines.each do |line|
      line_nr += 1
      if analyse_one_message_line(project_name, language2, filename, line_nr, line) && language2.eql?(L10N_Cache::JavaLanguage)
      end
    end
    puts "#{project_name} added #{filename} info #{info}" if $VERBOSE
  end

  def get_project_name(project_dir)
    project_xml = Document.new(File.new(File.join(project_dir, ".project")))
    project_name  = project_xml.elements['projectDescription'].elements['name'].text
  end

  def parse_plugin_and_messages
    start_dir = Dir.pwd
    @@directories.each do |directory|
      @main_dir = File.expand_path(directory)
      Dir.chdir(@main_dir)
      projects = (Dir.glob("**/.project") + Dir.glob('.project')).uniq.compact
      projects.each do |project|
        Dir.chdir(@main_dir)
        project_dir = File.expand_path(File.dirname(project))
        Dir.chdir(project_dir)
        @repository = calculate_repository_origin(project_dir)
        project_name  = get_project_name(project_dir)
        next if /test.*$|feature/i.match(project_name)
        msg_files = Dir.glob(File.join(project_dir, 'src', '**/messages*.properties'))
        if plugin_xml = File.join(project_dir, 'plugin.xml')
          parse_plugin_xml(project_name, plugin_xml)
        end
        puts "#{directory}: msg_files are #{msg_files}" if $VERBOSE
        if msg_files.size == 0
          puts "Skipping #{Dir.pwd}" if $VERBOSE
        else
          puts "#{Dir.pwd} found #{msg_files.size} messages files"
          msg_files.each{|msg_file| analyse_one_message_file(project_name, msg_file) }
          next
        end
      end
    end
  end

  def calculate_repository_origin(directory = Dir.pwd)
    git_config =  `git config  --local remote.origin.url`.chomp.split('/').last
    unless git_config && git_config.length > 0
      @repository = 'unknown'
    else
      @repository = git_config.sub(/\.git$/, '')
    end
  end

  def start_with_lang_in_parenthesis(line, lang)
  	/^\(#{lang}/.match(line)
  end

  def add_google_translation(source_lang, string2translate, lang)
    unless string2translate
      puts "Skipping #{project_id} #{string2translate} as no source found"      
      return
    end
    # translate_text(what, target_language='it', source_language='de')
    CGI.unescapeHTML(GoogleTranslation.translate_text(string2translate, lang, source_lang))
  end

  def add_csv_to_db_texts(csv_file)
    puts "Adding missing entries for  #{csv_file}"
    msgs_to_add = read_translation_csv(ARGV.first)
    inserts = {}
    msgs_to_add.each do |tag_name, value|
      next unless tag_name
      german_translation = L10N_Cache.get_translation(tag_name, 'de')
      L10N_Cache::CSV_KEYS.each do |lang|
        next if lang.eql?(L10N_Cache::JavaLanguage)
        current_translation = L10N_Cache.get_translation(tag_name, lang)
        binding.pry unless current_translation
        if current_translation.size == 0
          if german_translation.size == 0
            next if lang.eql?('en')
            java_translation = L10N_Cache.get_translation(tag_name, L10N_Cache::JavaLanguage)
            translated = add_google_translation('en', java_translation, lang)
          else
            translated = add_google_translation('de', german_translation, lang)
          end
          puts "Adding #{translated} missing translation for #{lang} #{tag_name}" if $VERBOSE
          L10N_Cache.set_translation(tag_name, lang, translated)
          inserts[[tag_name, lang]] =   translated
          next
        end
      end
    end
    puts "Inserted #{inserts.size} missing entries of #{msgs_to_add.size}"
    msgs_to_add
  end
 def add_missing
    main_language = 'de'
    raise "You must specify a CSV to add" unless ARGV.size == 1
    csv_file = ARGV.first
    raise "You must specify a file not a directory?" if File.directory?(csv_file)
    messages = add_csv_to_db_texts(csv_file)
    L10N_Cache::save_cache(csv_file)
  end

  def gen_languages_csv(filename, msgs)
    L10N_Cache::save_cache(filename)
    filename
  end

  def to_csv
    @@directories = [main_dir]
    @gen_csv = true
    parse_plugin_and_messages
    L10N_Cache.save_cache
    # gen_languages_csv(File.join(start_dir, L10N_Cache::TRANSLATIONS_CSV_NAME), @@all_msgs) if gen_csv
  end


  def read_translation_csv(csv_file)
  all_msgs = {}
  return all_msgs unless File.exist?(csv_file)
  index = 0
  @languages = []
    CSV.foreach(csv_file, :force_quotes => true) do |cells|
      index += 1 
      if index == 1
        raise("#{csv_file} has invalid header #{cells}") unless cells[0..L10N_Cache::CSV_HEADER_START.size-1] == L10N_Cache::CSV_HEADER_START
        @languages = cells[L10N_Cache::CSV_HEADER_SIZE..-1]
        next
      end
      key = cells[0..L10N_Cache::CSV_HEADER_START.size-1]
      key = key.first if  L10N_Cache::CSV_HEADER_SIZE == 1
      all_msgs[key] ||= {}
      @languages.each_with_index do |lang, index|
        all_msgs[key][lang] = "#{cells[index + L10N_Cache::CSV_HEADER_SIZE]}"
      end
    end
    all_msgs
  end

  def generate_plugin_properties(project_name, filename)
    puts "Generating plugin properties for #{File.expand_path(filename)}"
    keys = []
    File.open(filename, 'r:ISO-8859-1').readlines.each do |line|
      key, value = get_key_value(line.chomp, replace_dots_by_underscore: false)
      keys << [project_name, key].join('_')
    end
    plugin_key_hash = parse_plugin_xml(project_name, File.join(File.dirname(filename), 'plugin.xml'))
    keys += plugin_key_hash.keys
    LanguageViews.keys.each do |lang|
      lang_file = filename.sub('.properties', (lang.eql?('Java') ? '' : '_' + lang) + '.properties')
      File.open(lang_file, 'w:ISO-8859-1') do |file|
        keys.each do |tag_name|
          next if /_false$/.match(tag_name)
          translations =   @@all_msgs[tag_name]        
          unless translations
            puts "Missing translation #{lang} for #{tag_name}"
            file.puts("#{tag_name}=")
            next
          end
          value =translations[ lang ]
          lang_value = translations[lang]
          lang_value = translations[L10N_Cache::JavaLanguage] if !lang_value || lang_value.empty?
          tag2write = tag_name.sub(project_name+'_','')
          next if tag2write.eql?('false')
          if !lang_value || lang_value.empty?
            puts "no #{lang} value found for #{tag2write}"
            next
          end
          begin
            file.puts "#{tag2write}=#{lang_value}".encode('ISO-8859-1', {invalid: :replace, undef: :replace, replace: ''})
          rescue => error
            puts "Could not write #{lang_file}: #{tag2write} for #{lang} #{lang_value}"
          end
        end
      end
    end
  end

  # TODO: Generate properties files for all languages by default, but do correct stuff in l10n.{lang}
  def to_properties
    Dir.chdir(main_dir)
    index = 0
    @@all_msgs  = read_translation_csv(File.join(start_dir, L10N_Cache::TRANSLATIONS_CSV_NAME))
    all_keys = @@all_msgs.keys.collect{|x| x }.uniq
    l10n_key =  all_keys.find{|x| /l10n$/.match(x)}
    # raise("Could not find the main l10n project among #{all_keys}") unless l10n_key
    Dir.glob("#{main_dir}/**/.project").each do |project|
      Dir.chdir(File.dirname(project))
      project_name  = get_project_name(File.dirname(project))
      puts "project_name is #{project_name}" if $VERBOSE
      files = Dir.glob(File.join(Dir.pwd, 'plugin.properties')) 
      files.each do |filename|
        puts "Fixing plugin for #{filename}"
        next if filename.split('.').index('target')
        generate_plugin_properties(project_name, filename) 
      end
      files = Dir.glob(File.join(Dir.pwd, '**/messages*.properties'))
      if Dir.pwd.index(/l10n\.[a-zA-Z]{2}$/) && files.size == 0
        raise "You must place a correct messages.propertis into #{Dir.pwd}"
      end
      files.each do |filename|
        keys = []
        next if filename.split('.').index('target')
        next if filename.split('/').index('target')
        m =  /_(..)\.properties/.match(filename)
        lang = m ?  m[1] : 'en'
        puts "Generating #{lang} for #{filename}"
        saved_content = File.open(filename, 'r:ISO-8859-1').readlines
        msg_java =filename.sub(/\.(de|fr|it|en)/, '').sub('messages.properties', 'Messages.java')
        unless File.exist?(msg_java)
          msg_java =File.join(Dir.pwd.sub(L10N_Cache::REGEX_TRAILING_LANG, ''), 'src', project_name.split('.'), 'Messages.java').gsub("/#{lang}/", '/')
        end
        if File.exist?(msg_java)
          keys = File.readlines(msg_java).collect{|line| m = /String\s+(\w+)\s*;/.match(line); [ project_name, m[1]] if m }.compact
          keys += File.readlines(msg_java).collect{|line| m = /String\s+(\w+)\s*;/.match(line); [ project_name.sub(/\.#{lang}$/, ''), m[1]] if m }.compact
          if keys.size == 0
            puts "Skipping #{msg_java} which contains no keys"
            next
          end
        else
          puts "Skipping #{msg_java}" if $VERBOSE
          next
        end

        File.open(filename, 'w:ISO-8859-1') do |file|
          keys.sort.uniq.each do |full_key|
            next unless full_key[1]
            project_id = full_key[0]
            tag_name, dummy =  get_key_value("#{full_key[1]}= 'dummy")
            tag_name = "#{project_name}_#{tag_name}" unless /^messages/i.match(File.basename(filename))

            if @@all_msgs[full_key]
              value =  @@all_msgs[full_key]
            else
              # search some variant
              value = @@all_msgs[  tag_name ]
              value ||= @@all_msgs[ [tag_name.sub(/./,'') ] ]
              value ||= @@all_msgs[ [tag_name.sub(/%/,'') ] ]
              unless value
                puts "Missing #{lang} translation for #{full_key.last}"
                file.puts("#{full_key.last}=")
                next
              end
            end
            lang_value = value[lang]
            lang_value = value[L10N_Cache::JavaLanguage] if !lang_value || lang_value.empty?
            if tag_name && (!lang_value || lang_value.empty?)
            lang_value ||= @@all_msgs[l10n_key, tag_name]
          end
            if !lang_value || lang_value.empty?
              puts "no #{lang} value found for #{full_key}"
              next
            end
            begin
              file.puts "#{tag_name}=#{lang_value}".encode('ISO-8859-1',  {invalid: :replace, undef: :replace, replace: ''})
            rescue => error
              binding.pry
            end
          end
        end
      end
    end
  end
end

parser = Trollop::Parser.new do
  version "#{File.basename(__FILE__, '.rb')} (c) 2017 by Niklaus Giger <niklaus.giger@member.fsf.org>"
  banner <<-EOS
#{version}
License: Eclipse Public License 1.0 (EPL)
Useage: #{File.basename(__FILE__)} [-options] [directory1 directory]
  help manipulating files needed for translations
  using Cachefile        #{GoogleTranslation::CacheFileCSV} (UTF-8)
    and SqLite3 database #{Sqlite3File}
EOS
  opt :to_csv   ,         "Create #{L10N_Cache::TRANSLATIONS_CSV_NAME}.csv for all languages with entries for all [manifests|plugin]*.properties ", :default => false, :short => '-c'
  opt :add_missing,       "Add missing translations for a given csv file via Googe Translator using $HOME/google_translation_cache.csv", :default => false, :short => '-a'
  opt :to_properties,     "Create [manifests|plugin]*.properties for all languages from #{L10N_Cache::TRANSLATIONS_CSV_NAME}\n\n ", :default => false, :short => '-t'
end

Options = Trollop::with_standard_exception_handling parser do
  raise Trollop::HelpNeeded if ARGV.empty? # show help screen
  parser.parse ARGV
end

# GoogleTranslation.translate_text('Gutschrift')
# GoogleTranslation.translate_text('elektronische Krankengeschichte')

i18n = I18nInfo.new(ARGV)
i18n.start_dir = Dir.pwd
i18n.main_dir ||= File.expand_path(ARGV.first) if ARGV.size > 0
i18n.main_dir ||= Dir.pwd 
i18n.to_csv if Options[:to_csv]
i18n.to_properties if Options[:to_properties]
i18n.add_missing if Options[:add_missing]
