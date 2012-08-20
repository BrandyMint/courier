## Полную документацию смотри на http://courier.icfdev.ru/

## Build status [![Build Status](https://secure.travis-ci.org/dapi/courier.png)](http://travis-ci.org/dapi/courier)#

## Courier

Базовый модуль для управления подпиской:

    Courier.subscribe user, :new_comments, @post
    Courier.unbubscribe ...

Запуск рассылки с указанным именем

    Courier.notify :new_post, @post
    Courier.notify :new_news_item, NewsItem.last

Этот метод находит всех пользователей подписанных на данную рассылку, в
независимост от того подписывались они на пост или подписывались на всю
рассылку (не указывался resource при подписке) и
передает их в рассылочный класс (наследника `Courier::Subscription`)

### Подписать пользователя

На указанную рассылку, при необходимости указыватся ресурс (например
`@post`). Тоже что и `Courier.subscribe` только через пользовательский
объект.

    user.subsribe :new_comments, @post
    user.subsribe :new_posts
    user.unsubsribe :new_posts

## Courier::Subscription::Base

Модель и базовый класс управления подпиской. Записи создаются
на стадии разработки приложения.

Поля модели:

* id
* name - имя попдиски
* type - класс управления
* access - уровень доступа на подписку (user/admin)
* subject - тема письма
* properties - serialized hash

Методы:

    subscribe user, resource=nil
    unsibscribe user, resource=nil

## Courier::Subscription::Base < Base

properties:

* subject_method - название метода у модели для вытаскивания темы письма
  (например `"subject"` или `"title"`). Если не установле то в качестве темы используется
  поле subject подписки


## Courier::SubscriptionUser

Матрица пользователь<->рассылка.

Поля модели

* subscription_id
* user_id
* resource_id
* resource_type


## Примеры


Как разослать письма вручную:

    Courier::Mailer.send( :new_comment,
                          User.first,
                          'test subjet', 
                          NewsItem.find(15761).comments.first
                         ).deliver
                         
                         
## Создание новой подписки

Вначале определяем подписку в lib/tasks/seed/courier.rake
                         
    Courier.create :user_posts do
        description 'Новые посты пользователя' # заголовок, который будет отображаться в my.investcafe.ru/subscriptions
        from 'Инвесткафе <no-reply@investcafe.ru>'
        subject '%{user.name.to_s} написал новый пост %{post.title}' # тема письма
        access :user #доступ к подписке, пользователи или админы
      end

Запускаем rake, чтобы подписка загрузилась в бд

    rake icf:seed:courier

Для формирования письма добавляем метод класса Courier::Mailer::Common, в app/mailers/courier/mailer/common.rb

    def user_posts(context)
      @post = context.post
      @subscriber = context.subscriber

      mail do |format|
        format.html { render :user_posts }
      end
    end
    
либо используем уже готовый шаблон.

Для вывода ссылки на подписку/отписку используйте хелпер

    = toggle_subscription_link user, :user_posts

первым параметром идет ресурс (на что подписываемся), потом идет название самой подписки.

После первой подписки идем на страницу my.investcafe.ru/subscriptions и проверяем как отображаются вновь добавленные.

## TODO

Доки: http://habrahabr.ru/blogs/ruby/138582/#habracut
