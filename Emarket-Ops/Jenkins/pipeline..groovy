productionFolder = "/home/sysadmin/emarket-ops/k8s-production"
stagingFolder = "/home/sysadmin/emarket-ops/k8s-staging"

deleteBeDeploymentPrd = "kubectl -n production delete -f emark-be-deployment.yaml"
applyBeDeploymentPrd = "kubectl -n production apply -f emark-be-deployment.yaml"

deleteFeDeploymentPrd = "kubectl -n production delete -f emark-fe-deployment.yaml"
applyFeDeploymentPrd = "kubectl -n production apply -f emark-fe-deployment.yaml"

deleteBeDeploymentStg = "kubectl -n staging delete -f emark-be-deployment.yaml"
applyBeDeploymentStg = "kubectl -n staging apply -f emark-be-deployment.yaml"

deleteFeDeploymentStg = "kubectl -n staging delete -f emark-fe-deployment.yaml"
applyFeDeploymentStg = "kubectl -n staging apply -f emark-fe-deployment.yaml"

gitPull = "git pull origin main"

def stopProcess(){
    if(params.project == "backend") {
        stage("stop") {
            if(params.environment == "production")
                sh "id && cd ${productionFolder} && ${deleteBeDeploymentPrd}"
            if(params.environment == "staging")
                sh "cd ${stagingFolder} && ${deleteBeDeploymentStg}"
        }
    }
    if(params.project == "frontend"){
        stage("stop") {
            if(params.environment == "production")
                sh "cd ${productionFolder} && ${deleteFeDeploymentPrd}"
            if(params.environment == "staging")
                sh "cd ${stagingFolder} && ${deleteFeDeploymentStg}"
        }
    }
}

def startProcess(){
    if(params.project == "backend") {
        stage("start") {
            if(params.environment == "production")
                sh "cd ${productionFolder} && ${gitPull} && ${applyBeDeploymentPrd}"
            if(params.environment == "staging")
                sh "cd ${stagingFolder} && ${gitPull} && ${applyBeDeploymentStg}"
            } 
        }
    if(params.project == "frontend"){
        stage("start") {
            if(params.environment == "production") 
                sh "cd ${productionFolder} && ${gitPull} && ${applyFeDeploymentPrd}"
            if(params.environment == "staging")
                sh "cd ${stagingFolder} && ${gitPull} && ${applyFeDeploymentStg}"
        }
    }
}

def updateProcess(){
    if(params.project == "backend") {
        if(params.environment == "production") {
            stage("update") {
                sh "cd ${productionFolder} && ${gitPull} && ${applyBeDeploymentPrd}"
            }
        }
        if(params.environment == "staging") {
            stage("update") {
                sh "cd ${stagingFolder} && ${gitPull} && ${applyBeDeploymentStg}"
            }
        }
        
    }
    if(params.project == "frontend") {
        if(params.environment == "production"){
            stage("update") {
                sh "cd ${productionFolder} && ${gitPull} && ${applyFeDeploymentPrd}"
            }
        }
        if(params.environment == "staging"){
            stage("update") {
                sh "cd ${stagingFolder} && ${gitPull} && ${applyFeDeploymentStg}"
            }
        }
    }
}

def rollbackProcess(){
    if(params.project == "backend") {
        stage("rollback") {
            sh """
                cd ${productionFolder} &&
                ${gitPull} &&
                sed -i 's|vvthienregistry.azurecr.io/emark-be-prd:latest|vvthienregistry.azurecr.io/emark-be-prd:${params.version_backend}|g' emark-be-deployment.yaml &&
                kubectl apply -f emark-be-deployment.yaml &&
                git stash save
            """
        }
    }
    if(params.project == "frontend") {
        stage("rollback") {
            sh """
                cd ${productionFolder} &&
                ${gitPull} &&
                sed -i 's|vvthienregistry.azurecr.io/emark-fe-prd:latest|vvthienregistry.azurecr.io/emark-fe-prd:${params.version_frontend}|g' emark-fe-deployment.yaml &&
                kubectl apply -f emark-fe-deployment.yaml &&
                git stash save
            """
        }
    }
}

node("bastion"){
    currentBuild.displayName = params.action + " " + params.project + " in " + params.environment + " environment"
    if (params.action == "stop") stopProcess()
    if (params.action == "start") startProcess()
    if (params.action == "restart"){
        stopProcess()
        startProcess()
    }
    if (params.action == "update") updateProcess()
    if (params.action == "rollback") rollbackProcess()
}