# Guía de Usuario para Desplegar Infraestructura en AWS usando Terraform y GitHub Actions con OIDC
## Prerrequisitos
Cuenta de AWS: Asegúrate de tener acceso a una cuenta de AWS.
Repositorio en GitHub: Clona el repositorio en GitHub donde está almacenado el código Terraform.
Permisos Adecuados en AWS: Necesitas permisos para crear roles y políticas en AWS.
Pasos para Configurar GitHub Actions y AWS

1. Configurar un Proveedor de Identidad OIDC en AWS
- Accede a la consola de AWS IAM.
- En el menú de la izquierda, selecciona Identity Providers.
- Haz clic en Add provider.
- Selecciona OpenID Connect.
- Introduce https://token.actions.githubusercontent.com como URL del proveedor.
- Introduce sts.amazonaws.com como ID de cliente.
- Haz clic en Add provider.

2. Crear una Política de IAM

- Accede a la consola de AWS IAM.
- En el menú de la izquierda, selecciona Policies.
- Haz clic en Create policy.
- Selecciona la pestaña JSON y pega la siguiente política:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "iam:*",
                "sts:AssumeRole"
            ],
            "Resource": "*"
        }
    ]
}
```

- Haz clic en Next: Tags.
- Añade etiquetas si es necesario, luego haz clic en Next: Review.
- Introduce un nombre para la política (por ejemplo, GitHubActionsPolicy) y haz clic en Create policy.

3. Crear un Rol de IAM
- Accede a la consola de AWS IAM.
- En el menú de la izquierda, selecciona Roles.
- Haz clic en Create role.
- Selecciona Web identity como tipo de entidad de confianza.
- Selecciona el proveedor de identidad OIDC que configuraste y el ID de cliente sts.amazonaws.com.
- Haz clic en Next: Permissions.
- Adjunta la política que creaste (GitHubActionsPolicy).
- Haz clic en Next: Tags.
- Añade etiquetas si es necesario, luego haz clic en Next: Review.
- Introduce un nombre para el rol (por ejemplo, GitHubActionsRole) y haz clic en Create role.

4. Configurar GitHub Actions
- Ve a tu repositorio en GitHub.
- Ve a Settings > Secrets and variables > Actions.
- Haz clic en New repository secret y agrega los siguientes secretos:
- IAM_ROLE_ARN: El ARN del rol de IAM que creaste.
