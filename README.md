# nas-access-rules-ad
This repository stands to share a script for adding permissions (access rule) on NAS resource for CIFS.

For those cases when we have NAS CIFS resources with to old data with owners that Active Directory does not know anynmore about.

Script allows to:
* Add an access rule based on: principal, rule, action
* If file/folder has a forgotten SID as owner it applies a provided one
