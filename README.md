Courier
=======

Давным давно, в одной далекой-предалекой галактике, был такой модем USR Courier, он хорошо держал карриер и был мечтой каждого фидошника. А сейчас чтобы получать много не нужных писем достаточно зарегистрироваться на еще одной социальной сети.

Чтобы помочь социальной сети справиться с большим количеством видов подписок и оповещений, а пользователю настроить способы их доставки мы разработали плагин Courier. Courier On Rails.

Courier - Универсальная система контроля пользовательских оповещений и подписок.

# Courier::Service (AR-модель) доставщики

Модель класса осуществляющего способ доставки.

## Поля:

* name - уникальное название (littlesms, actionmailer)
* way (sms/email/twitter)
* type (класс)

## Например (классы)

* Courier::Service::SMS::LittleSMS
* Courier::Service::Email::ActionMailer
* Courier::Service::Email::Mailchimp
* Courier::Service::Twitter::Grackle
* Courier::Service::ControllerFlash

доставщики подключаются через команду Courier.register_service(SMS::LittleSMS, Email::ActionMailer,.. ) в config/initializers/courier.rb

Третий неймспейс в названии класс доставщика (SMS/Email/Twitter) обозначает направление доставки (way). В одном направлени может быть зарегистрирован только один доставщик.

## Методы

* deliver!(message) - осуществляет собственно доставку сообщения используя указанный шаблон `template.render(message)`. Если доставка удалась устанавливает сообщению message.mark_as_delivered

# Courier::Templates (AR-модель)

Описывают тип сообщения (название). Возможно будут соделжать шаблон или ссылку на него.

## Поля

* key
* state (:deliver, :none, :new, :broken)
* details

## Методы

* render(message) - подготавливает текст для соответствующего сообщения согласно пользовательским настройкам (Courier::SenderSettings#state)

## Например:

* :comments_in_my_plan - оставили комментарий в моем плане
* :comments_in_commented_plan - оставили комментарий в событии которо я прокомментировал
* :plan_notice - за __ минут до плана
* :attend пригласили

# Courier::SenderSettings (AR-модель)

Индивидуальные настройки для каждого пользователя. Матрица пересечения пользователь-сервис-тип сообщения.

## Поля

* sender_id
* sender_type
* template_id (может быть все - nil)
* service_id (может быть все - nil)
* state (:send, :none, :save)

# Courier::Sender (extenstion для AR-модели пользователя-отправителя)

Подключается через `acts_as_sender` дает модели метод `message(key, options)`. Пример вызова:

@@@
user.notify :comments_in_my_plan, :comments=>@comments, :level=>:success
user.notify_failure :cant_import_plans, :provider=>:facebook
@@@

# Courier::Messages (AR-модель)

Таблица сообщений к отправке.

Сообщения добавляются через user.message

## Поля

* sender_id
* sender_type 
* template_id
* delivered_at
* level (:warning, :notice, :failure etc)
* message
* options

## Методы

* Instance
   * remove_after_delivery (true/false)
   * mark_as_delivered (удаляет или устанавливает в сообщении delivered_at)
   * deliver! - отправляет сообщение. Вызывает в каждом сервисе (Courier::Service.all.each &:deliver! message)
* Class
   * fresh
   * delivered
   * deliver_all! - отправляет все новые. Вызывает для каждого fresh сообщения deliver!

# Courier - общий модуль доставки

Методы:

* register_service (добавляет если нет такого сервиса в таблице сервисов, проверяет на уникальность way)
* get_service_by_way, get_service_by_name - возвращают объект доставщика
* deliver_all! - вызывает Courier::Message.deliver_all!




Интерфейс для пользователя:
--------------------------

user.courier.templates - массив всех шаблонов с настройкой под каждый сервис

user.courier.template(:contacts_imported).disable / enable
user.courier.template(:contacts_imported).enabled? disabled?
user.courier.service(:email).disable_all / enable_all

user.courier.bootstrap!

user.courier.message
user.message 