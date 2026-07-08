package terraform.policies.deny_open_ssh

test_deny_ssh_open_to_world if {
	count(deny) > 0 with input as {
		"resource_changes": [{
			"address": "aws_security_group.bad_example",
			"type": "aws_security_group",
			"change": {
				"actions": ["create"],
				"after": {
					"ingress": [{
						"from_port": 22,
						"to_port": 22,
						"cidr_blocks": ["0.0.0.0/0"]
					}]
				}
			}
		}]
	}
}

test_allow_ssh_restricted if {
	count(deny) == 0 with input as {
		"resource_changes": [{
			"address": "aws_security_group.good_example",
			"type": "aws_security_group",
			"change": {
				"actions": ["create"],
				"after": {
					"ingress": [{
						"from_port": 22,
						"to_port": 22,
						"cidr_blocks": ["190.100.50.0/32"]
					}]
				}
			}
		}]
	}
}
