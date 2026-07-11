# Evaluación Final Transversal – Infraestructura como Código II (AUY1105)

**Estudiante:** Eduardo Urbina
**Repositorio de este proyecto:** https://github.com/edoturb/iac-final-aws
**Repositorio del módulo:** https://github.com/edoturb/terraform-aws-vpc-simple
**Módulo en Terraform Registry:** [confirmar y pegar aquí el link exacto de la evidencia #8]

---

## 1. Introducción

Este proyecto consolida el trabajo desarrollado en los Parciales 1, 2 y 3 de la
asignatura, integrando en una única solución de Infraestructura como Código
(IaC) los siguientes componentes: [ajusta este párrafo a lo que realmente hiciste
en cada parcial]

- **Parcial 1:** flujo de trabajo colaborativo con Git/GitHub, revisiones de
  código mediante Pull Requests, y análisis estático de código (TFLint, Checkov).
- **Parcial 2:** definición de políticas de seguridad como código (OPA/Rego)
  y un sistema de permisos automatizado que evalúa cambios propuestos antes
  de permitir su despliegue.
- **Parcial 3:** desarrollo de un módulo de Terraform reutilizable, documentado
  y versionado semánticamente, publicado como referencia consumible.

La solución final despliega una infraestructura de red básica en AWS (VPC,
subredes, Security Group e instancia EC2) utilizando Terraform, con un pipeline
CI/CD en GitHub Actions que automatiza validación, análisis de calidad,
aplicación de políticas de seguridad y despliegue.

## 2. Alcance

**Objetivos a cumplir:**
- Desplegar infraestructura de red reproducible y segura en AWS mediante un
  módulo Terraform reutilizable.
- Automatizar el ciclo de vida del despliegue (CI/CD) con gates de calidad y
  seguridad obligatorios antes de aplicar cambios.
- Mantener trazabilidad y gobierno mediante Pull Requests, políticas como
  código y versionado semántico.

**Recursos necesarios:**
- Cuenta AWS (capa gratuita) con usuario IAM con permisos programáticos.
- Cuenta de GitHub (repositorio público para publicar el módulo en el Terraform Registry).
- Terraform CLI >= 1.6, AWS CLI, TFLint, Checkov, OPA/Conftest instalados localmente.

**Criterios de éxito:**
- `terraform plan`/`apply` se ejecutan sin errores contra AWS.
- El pipeline de CI bloquea automáticamente un PR que viole una política de
  seguridad (ej. SSH abierto a `0.0.0.0/0`) o que falle análisis estático.
- El despliegue a `main` requiere aprobación manual (gate de permisos).
- El módulo está documentado, versionado (tags `vX.Y.Z`) y es reutilizable.

## 3. Diseño de la solución

### 3.1 Componentes principales

| Componente | Herramienta | Función |
|---|---|---|
| Infraestructura | Terraform + AWS Provider | VPC, subredes, IGW, Security Group, EC2 |
| Módulo reutilizable | `modules/vpc-simple` | Encapsula la red, versionado semánticamente |
| Control de versiones | Git / GitHub | Historial, ramas, Pull Requests |
| Revisión de código | GitHub PR + CODEOWNERS | Obliga revisión antes de fusionar |
| Análisis estático | TFLint, Checkov | Calidad de código y vulnerabilidades |
| Políticas de seguridad | OPA / Conftest (Rego) | Reglas de cumplimiento como código |
| Sistema de permisos | GitHub Branch Protection + Environments | Permite/deniega merge y apply automáticamente |
| CI/CD | GitHub Actions | `terraform-ci.yml` (validación en PR) y `terraform-cd.yml` (despliegue en main) |
| Estado remoto | S3 + DynamoDB (lock) | Estado centralizado y bloqueo de concurrencia |

### 3.2 Flujo de trabajo (de código a despliegue)

1. Se crea una rama a partir de `main` y se modifica código Terraform.
2. Se abre un Pull Request → se ejecuta `terraform-ci.yml`:
   - `terraform fmt` y `terraform validate`
   - TFLint y Checkov (análisis estático)
   - `terraform plan` convertido a JSON y evaluado por Conftest contra las
     políticas de `policy/` (sistema de permisos automatizado: si una política
     falla, el check falla y GitHub Branch Protection bloquea el merge).
3. Un revisor (CODEOWNERS) aprueba el PR dejando comentarios documentados.
4. Al hacer merge a `main`, se dispara `terraform-cd.yml`, que requiere
   aprobación manual en el Environment `production-approval` antes de ejecutar
   `terraform apply`.
5. El estado se guarda remotamente en S3 con bloqueo vía DynamoDB.

### 3.3 Políticas de seguridad implementadas

- **`require_tags.rego`**: exige tags `Environment` y `Owner` en recursos
  clave (trazabilidad y cumplimiento).
- **`deny_open_ssh.rego`**: deniega cualquier Security Group que exponga el
  puerto 22 a `0.0.0.0/0`.

Ambas cuentan con pruebas unitarias (`policy/tests/`) ejecutadas en el pipeline.

## 4. Diagrama de la arquitectura

**Arquitectura de red en AWS:**

![Arquitectura de red](docs/diagrama-arquitectura-red.svg)

**Flujo del pipeline CI/CD:**

![Pipeline CI/CD](docs/diagrama-pipeline-cicd.svg)

## 5. Conclusiones

La solución implementada aborda de manera integral los requisitos definidos
en los Parciales 1, 2 y 3: se automatiza el ciclo de vida completo de la
infraestructura desde la revisión de código hasta el despliegue en la nube,
incorporando controles de calidad (análisis estático), controles de
seguridad (políticas como código con evaluación automatizada) y buenas
prácticas de modularidad, documentación y versionado semántico. Esto asegura
un flujo de entrega continuo, auditable y alineado con estándares de la
industria para Infraestructura como Código.

[Amplía este párrafo con tu experiencia concreta: qué funcionó, qué tuviste
que ajustar, qué aprendiste.]

## 6. Anexos

- **GitHub Repository (proyecto):** https://github.com/edoturb/iac-final-aws
- **GitHub Repository (módulo):** https://github.com/edoturb/terraform-aws-vpc-simple
- **Terraform Registry:** [confirmar y pegar aquí el link exacto — visible en la evidencia #8 abajo]
- **Evidencia (capturas):** ver carpeta `docs/evidencia/` y sección 7 a continuación

## 7. Evidencia

Capturas del proceso completo de implementación, en orden cronológico.

### 7.1 Preparación del entorno y control de versiones

**Cuenta AWS activa y conectada** (AWS Academy Learner Lab, credenciales STS
verificadas con `aws sts get-caller-identity`):

![Cuenta AWS activa](docs/evidencia/01-cuenta-aws-activa.png)

**Creación del repositorio en GitHub** para el proyecto consolidado:

![Creación repositorio GitHub](docs/evidencia/02-creacion-repositorio-github.png)

### 7.2 Módulo Terraform reutilizable (IL3.1, IL3.2, IL3.3)

**Push inicial del módulo `vpc-simple`** a su repositorio independiente
`terraform-aws-vpc-simple` (requisito del Terraform Registry: el módulo debe
vivir en su propio repo público):

![Push inicial del módulo](docs/evidencia/03-push-inicial-modulo-vpc-simple.png)

**Estructura publicada del repositorio del módulo** (main.tf, variables.tf,
outputs.tf, README.md con documentación de uso — IL3.1 / IL3.2):

![Estructura del repositorio del módulo](docs/evidencia/04-repositorio-terraform-aws-vpc-simple.png)

**Versionado semántico — tag `v1.0.0` publicado** (IL3.3):

![Tag v1.0.0 publicado en GitHub](docs/evidencia/06-versionado-semantico-tag-v1.0.0.png)

**Comandos de versionado semántico en terminal** (`git tag v1.0.0` / `git push origin v1.0.0`):

![Versionado semántico desde terminal](docs/evidencia/07-versionado-semantico-terminal.png)

**Módulo publicado en el Terraform Registry** — evidencia formal del anexo
obligatorio de la pauta:

![Módulo publicado en Terraform Registry](docs/evidencia/08-modulo-publicado-terraform-registry.png)

### 7.3 Políticas de seguridad como código (IL2.1, IL2.2, IL2.3)

**Política de seguridad implementada** (`deny_open_ssh.rego` — deniega
security groups con el puerto 22 abierto a `0.0.0.0/0`):

![Política de seguridad](docs/evidencia/05-politica-de-seguridad.png)

### 7.4 Análisis estático de código (IL1.2)

**TFLint corriendo en el pipeline de CI**, validando buenas prácticas de
codificación Terraform:

![TFLint en CI](docs/evidencia/09-tflint-en-ci.png)

**Checkov corriendo en el pipeline**, evaluando vulnerabilidades y
desviaciones de configuración segura:

![Checkov en CI](docs/evidencia/10-checkov.png)

### 7.5 Flujo de revisión de código vía Pull Request (IL1.1)

**Comentario de revisión documentado en el PR**, explicando el motivo del
cambio y la sugerencia técnica aplicada:

![Comentario de revisión en PR](docs/evidencia/11-comentario-revision-pr.png)

**Pull Request mergeado** — flujo completo de revisión de código: rama →
PR → checks de CI en verde → aprobación → merge a `main`:

![Pull Request mergeado](docs/evidencia/12-pull-request-mergeado.png)

### 7.6 Despliegue de infraestructura en AWS

**`terraform plan` exitoso** — 8 recursos a crear, 0 errores, confirmando
que el diseño de la solución es válido antes de tocar la nube:

![Terraform plan exitoso](docs/evidencia/13-terraform-plan-exitoso.png)

**`terraform apply` exitoso** — infraestructura efectivamente creada en AWS:

![Terraform apply exitoso](docs/evidencia/14-terraform-apply-exitoso.png)

**VPC desplegada, vista desde la consola de AWS**:

![VPC desplegada en consola AWS](docs/evidencia/15-vpc-desplegada-consola.png)

**Instancia EC2 desplegada dentro de la subred pública**:

![Instancia EC2 desplegada](docs/evidencia/16-ec2-instancia-desplegada.png)

---

## Cómo desplegar este proyecto (para el docente/replicación)

```bash
cd environments/dev
terraform init
terraform plan -var="owner=nombre" -var="allowed_ssh_cidr=TU.IP/32"
terraform apply -var="owner=nombre" -var="allowed_ssh_cidr=TU.IP/32"
```

Ver [`modules/vpc-simple/README.md`](modules/vpc-simple/README.md) para la
documentación del módulo reutilizable.
