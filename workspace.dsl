workspace {

    model {
        # Users
        publicUser = person "Public User"
        authorizedUser = person "Authorized User"

        # External Software Systems
        bookStoreSystem = softwareSystem "Book Store System" "Allows users to interact with book records" "Target System" {
            # Level 2: Container
            searchWebAPI = container "Search Web API" "Allows only authorized users searching books records" "Go" "Web API"
            
            adminWebAPI = container "Admin Web API" "Allows only authorized users administering books details" "Go" "Web API" {
                # Level 3: Component
                bookService = component "service.Book" "Allow administering books details"
                authorizerService = component "service.Authorizer" "Allows authorizing users by using external Authorization System"
                eventPublisherService = component "service.EventsPublisher" "Publishes books-related events to Events Publisher"
            
            }

            publicWebAPI = container "Public Web API" "Allows Public users getting books details" "Go"

            bookKafkaSystem = container "Book Kafka System" "Handles book-related domain events" "Apache Kafka 3.0"

            elasticSearchEventConsumer = container "ElasticSearch Events Consumer" "Listening to Kafka domain events and write publisher to Search Database for updating" "Go"

            searchDatabase = container "Search Database" "Stores searchable books details" "ElasticSearch" "Database"

            relationalDatabase = container "Read/Write Relational Database" "Stores books details" "PostgreSQL" "Database"

            readerCache = container "Reader Cache" "Caches book details" "Memcached"

            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "Listening to external events coming from Publisher System"  "Kafka"
        }

        # External Software Systems
        authorizedSystem = softwareSystem "Authorized System" "External System"
        publisherSystem = softwareSystem "Publisher System" "External System"

        # Relationship between People and Software Systems
        publicUser -> bookStoreSystem "Use"
        authorizedUser -> bookStoreSystem "Use"
        authorizedSystem -> publicUser "Providing authorization"
        authorizedSystem -> authorizedUser "Providing authorization"

        # Relationship between Software Systems and External System
        bookStoreSystem -> authorizedSystem "Authorize using"
        bookStoreSystem -> publisherSystem "Giving details abouts books using"

        # Relationship between Containers
        authorizedUser -> searchWebAPI "Searching books records" "HTTPS"
        searchWebAPI -> searchDatabase "Use as a search database for searching read-only records"
        authorizedUser -> adminWebAPI "Administering books details" "HTTP"
        adminWebAPI -> relationalDatabase "Read data from and write data to"
        publicUser -> publicWebAPI "Getting books details"
        publicWebAPI -> relationalDatabase "Read data from"
        publicWebAPI -> readerCache "Read/Write data to"
        elasticSearchEventConsumer -> bookKafkaSystem "Listening to"
        elasticSearchEventConsumer -> searchDatabase "Writing publisher for updating"
        publisherRecurrentUpdater -> adminWebAPI "Updating detail data"


        # Relationship between Containers and External System
        searchWebAPI -> authorizedSystem "Authorized by"
        publisherRecurrentUpdater -> publisherSystem "Listening to external events coming"
        adminWebAPI -> authorizedSystem "Authorized by"

        # Relationship between Components


        # Relationship between Components and Other Containers and Systems
        eventPublisherService -> bookKafkaSystem "Publishing books-related domain events"
        eventPublisherService -> relationalDatabase "Read form and write data"
        authorizerService -> authorizedSystem "Using"

        #Dynamic Diagram
        developer = person "Developer"
        repo = softwareSystem "Source code Repository" "Github"
        awsCloud = softwareSystem "AWS Cloud CI/CD" {
            codePipeline = container "CodePipeline" "Downloads the source code and starts the build process."
            codeBuild = container "CodeBuild" "Downloads the necessary source files and starts running commands to build and tag a local Docker container image."
            amzECR = container "Amazon ECR"
            amzEKS = container "Amazon EKS"
        }

        developer -> repo "Push code"
        repo -> codePipeline "Trigger"
        codePipeline -> codeBuild "Download source code"
        codeBuild -> amzECR "Push container image"
        amzECR -> codeBuild "pull docker image"
        codeBuild -> amzEKS "deploy image"
    }

    views {
        # Level 1
        systemContext bookStoreSystem "SystemContext" {
            include *
            # default: tb,
            # support tb, bt, lr, rl
            autoLayout
        }
        # # Level 2
        container bookStoreSystem "Containers" {
            include *
            autoLayout lr
        }
        component adminWebAPI "Components" {
            include *
            autoLayout
        }

        dynamic awsCloud "Deployment" "" {
            developer -> repo 
            repo -> codePipeline 
            codePipeline -> codeBuild 
            codeBuild -> amzECR
            amzECR -> codeBuild
            codeBuild -> amzEKS

            autoLayout 
        }

        styles {
            element "Customer" {
                background #08427B
                color #ffffff
                fontSize 22
                shape Person
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            element "Database" {
                shape Cylinder
            }
        }

        theme default
    }

}