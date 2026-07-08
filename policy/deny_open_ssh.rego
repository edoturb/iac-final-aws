package terraform.policies.deny_open_ssh

# IL2.2 / IL2.3 - Sistema de permisos automatizado: deniega cualquier
# security group que exponga el puerto 22 a 0.0.0.0/0.

deny contains msg if {
	some address, rc in input.resource_changes
	rc.type == "aws_security_group"
	action := rc.change.actions
	action[_] != "delete"
	some ingress in rc.change.after.ingress
	ingress.from_port <= 22
	ingress.to_port >= 22
	"0.0.0.0/0" in ingress.cidr_blocks
	msg := sprintf("Recurso '%s' expone el puerto 22 (SSH) a 0.0.0.0/0. Prohibido por politica de seguridad.", [address])
}
