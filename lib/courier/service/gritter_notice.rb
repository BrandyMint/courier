# -*- coding: utf-8 -*-

class Courier::Service::GritterNotice < Courier::Service::Base
  def initialize
    raise "No GritterNotices. Add gem 'gritter_notices' to Gemfile." unless defined? GritterNotices
    super
  end

  #
  # В локале создается хеш всех параметров принимаемых GritterNotice
  #
  # template_key:
  #   title: Внимание!
  #   text: Ва прошли на новый уровень
  #   level: warning
  #   image: /images/warning.png
  #
  #

  def message(owner, template, options)
    options[:scope]=[:courier, :gritter_notice] unless options[:scope]
    owner.gritter_notice template.name, I18n::translate(template.name, options )
  end

  def deliver!
    # Nothng to do, it's realtime delivered
  end
end
