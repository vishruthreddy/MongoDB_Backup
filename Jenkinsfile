pipeline {
    agent any

    parameters {
        booleanParam(name: 'RUN_RESTORE', defaultValue: false, description: 'Run restore operation?')
        string(name: 'RESTORE_DATE', defaultValue: '2025-06-04', description: 'Backup date to restore (YYYY-MM-DD)')
    }

    stages {
        stage('Run MongoDB Backup/Restore') {
            steps {
                script {
                    if (params.RUN_RESTORE) {
                        sh '''
                        ansible-playbook -i inventory.ini mongo_backup_restore.yml                           --extra-vars "mode=restore backup_date=${RESTORE_DATE}"
                        '''
                    } else {
                        sh '''
                        ansible-playbook -i inventory.ini mongo_backup_restore.yml                           --extra-vars "mode=backup"
                        '''
                    }
                }
            }
        }
    }
}
