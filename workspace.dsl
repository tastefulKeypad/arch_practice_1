workspace "Name" "Description" {
    !identifiers hierarchical

    model {
        user  = person "Пользователь" "Рядовой пользователь или администратор"
        emailService = softwareSystem "Email Сервис" "Внешний сервис отправки уведомлений по email" {
            tags "External"
        }
        paymentService = softwareSystem "Сервис онлайн платежей" "Внешний сервис проведения оплаты" {
            tags "External"
        }

        carRentSystem = softwareSystem "Система управления арендой автомобилей" {
            database = container "База данных SQALchemy" "База данных для хранения информации о пользователях, автомобилях и истории аренды" "SQALchemy" {
                tags "Database"
            }
            webApp = container "Веб приложение" "Web Application" {
                tags "Service"
            }
            endpointService = container "Единая точка входа API" "Единая точка входа для всех API запросов, маршрутизирует запросы к соответствующим сервисам" "FastAPI" {
                tags "Service"
            }
            userService = container "Клиентский сервис" "Управление пользовательскими данными: регистрация, поиск" "Python" {
                tags "Service"
            }
            autoService = container "Сервис автопарка" "Поиск и получение списка доступных автомобилей, добавление автомобилей в парк" "Python" {
                tags "Service"
            }
            rentService = container "Сервис аренды" "Аренда автомобиля, завершение и просмотр истории аренд" "Python" {
                tags "Service"
            }
            authService = container "Сервис авторизации" "Авторизация пользователя с генерацией JWT токена" "Python" {
                tags "Service"
            }
        }


        user -> carRentSystem "Обращается к системе через веб-интерфейс" "HTTPS"
        user -> carRentSystem.webApp "Обращается к системе через веб-интерфейс" "HTTPS"

        carRentSystem.webApp -> carRentSystem.endpointService "API запрос" "HTTPS/REST"
        carRentSystem.endpointService -> carRentSystem.userService "Управление пользователями" "HTTPS/REST"
        carRentSystem.endpointService -> carRentSystem.rentService "Управление арендой и доступ к истории аренд" "HTTPS/REST"
        carRentSystem.endpointService -> carRentSystem.autoService "Управление и доступ к автопарку" "HTTPS/REST"
        carRentSystem.endpointService -> carRentSystem.authService "Авторизация пользоватилей и их валидация" "HTTPS/REST"
        carRentSystem.rentService -> carRentSystem.autoService "Проверка наличия свободных автомобилей" "HTTPS/REST"

        carRentSystem.userService -> carRentSystem.database "Читает и записывает данные о пользователях"
        carRentSystem.autoService -> carRentSystem.database "Читает и записывает данные об автомобилях"
        carRentSystem.rentService -> carRentSystem.database "Читает и записывает данные об аренде"
        carRentSystem.authService -> carRentSystem.database "Проверяет сходимость логина и пароля с указанными в базе данных"

        carRentSystem -> emailService "Отправляет уведомления по email" "SMPT"
        carRentSystem.userService -> emailService "Отправляет код подтверждения при регистрации" "SMPT"
        carRentSystem.rentService -> emailService "Отправляет напоминания об активной аренде" "SMPT"
        carRentSystem -> paymentService "Перенаправляет на сайт для оплаты аренды" "HTTPS"
        carRentSystem.rentService -> paymentService "Перенаправляет на сайт для оплаты аренды" "HTTPS"
    }

    views {
        systemContext carRentSystem "GeneralOverview" {
            include *
            autolayout lr
            title "System Context - Система управления арендой автомобилей"
            description "Диаграмма контекста системы, показывающая взаимодействие пользователей и внешних систем с системой управления арендой автомобилей"
        }

        container carRentSystem "InternalOverview" {
            include *
            autolayout lr
            title "Container - Внутренняя архитектура системы управления арендой автомобилей"
            description "Диаграмма контейнеров системы, показывающая внутреннюю структуру системы и взаимодействие между компонентами"
        }

        dynamic carRentSystem "DynamicRentPrepay" {
            autolayout lr
            title "Dynamic - Создание новой аренды с предоплатой"
            description "Последовательность взаимодействия компонентов при создании новой аренды с предоплатой"
            user -> carRentSystem.webApp "Отправляет запрос о создании новой аренды формата 'КлассАвтомобиля' 'ДатаНачало' 'ДатаКонец' 'МестоНачало' 'МестоКонец'"
            carRentSystem.webApp -> carRentSystem.endpointService "Маршрутизирует запрос"
            carRentSystem.endpointService -> carRentSystem.authService "Проверяет аутентификацию пользователя"
            carRentSystem.authService -> carRentSystem.endpointService "Подтверждает аутентификацию пользователя"
            carRentSystem.endpointService -> carRentSystem.autoService "Проверяет наличие свободных автомобилей желаемого класса на указанный временной промежуток"
            carRentSystem.autoService -> carRentSystem.rentService "Подтверждает наличие свободных автомобилей"
            carRentSystem.rentService -> paymentService "Перенаправляет пользователя на сайт для проведения предоплаты"
            paymentService -> carRentSystem.rentService "Возвращает подтверждение об успешно пройденной оплате"
            carRentSystem.rentService -> carRentSystem.database "Сохраняет информацию об аренде в БД"
            carRentSystem.rentService -> emailService "Направляет пользователю на электронную почту сообщение с информацией об аренде"
            carRentSystem.rentService -> carRentSystem.endpointService "Возвращает информацию об успешной аренде"
            carRentSystem.endpointService -> carRentSystem.webApp "Возвращает на веб приложение информацию об успешной аренде"
            carRentSystem.webApp -> user "Отображение информации об успешной аренде"
        }



        styles {
# Color palette:
#E32942
#E36D29
#E3CA29
#29E3CA
#2942E3
            element "Person" {
                shape person
                stroke #2942E3
                background #2942E3
                color #000000
            }
            element "External" {
                shape roundedBox
                stroke #29E3CA
                background #29E3CA
                color #000000
            }
            element "Database" {
                shape cylinder
                color #E32942
                background #E32942
                color #000000
            }
            element "Service" {
                shape roundedBox
                color #E36D29
                background #E36D29
                color #000000
            }
            element "Element" {
                color #000000
            }
        }
    }

}

