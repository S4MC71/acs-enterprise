FROM alpine:3.19

RUN apk add --no-cache \
    openssh \
    bash \
    curl \
    iputils \
    iproute2 \
    net-tools \
    shadow \
    sudo \
    vim \
    less

# Setup SSH Server
RUN ssh-keygen -A && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config && \
    echo "GatewayPorts yes" >> /etc/ssh/sshd_config && \
    echo "X11Forwarding no" >> /etc/ssh/sshd_config && \
    echo "Banner /etc/ssh/ssh_banner" >> /etc/ssh/sshd_config

# Corporate SSH Login Banner
RUN printf '%s\n' \
    "╔══════════════════════════════════════════════════════════╗" \
    "║   NEXUS GLOBAL ENTERPRISE — SSH BASTION HOST (DMZ)      ║" \
    "║   Node: bastion.nexus.internal | IP: 10.0.1.40          ║" \
    "║                                                          ║" \
    "║   ** AUTHORIZED PERSONNEL ONLY **                        ║" \
    "║   All sessions are monitored, logged, and recorded.      ║" \
    "║   Unauthorized access will be prosecuted.                ║" \
    "║                                                          ║" \
    "║   For SSH key access, contact: tahmed@nexus.internal     ║" \
    "╚══════════════════════════════════════════════════════════╝" \
    > /etc/ssh/ssh_banner

# MOTD after login
RUN printf '%s\n' \
    "" \
    "Welcome to Nexus Global Enterprise Bastion Host" \
    "================================================" \
    "This host provides SSH gateway access to internal corporate subnets." \
    "" \
    "Internal Routes available via this Bastion:" \
    "  Core Backbone:  10.0.2.0/24  (AD-DC, SIEM)" \
    "  Data Center:    10.0.3.0/24  (ERP, DB, SAN)" \
    "  Campus Clients: 10.0.4.0/24  (Workstations)" \
    "" \
    "Usage: ssh -J devops-remote@bastion.nexus.internal <internal_host>" \
    "" \
    > /etc/motd

# Create bastion operator account (intentionally weak password for brute-force scenario)
RUN adduser -D -s /bin/bash devops-remote && \
    echo "devops-remote:devops-remote@123" | chpasswd

# Seed bastion operator's history and known hosts
USER devops-remote
WORKDIR /home/devops-remote

RUN mkdir -p /home/devops-remote/.ssh && \
    chmod 700 /home/devops-remote/.ssh

RUN printf '%s\n' \
    "ssh tahmed@10.0.4.20" \
    "ssh sjenkins@10.0.4.10" \
    "ping -c 2 10.0.2.10" \
    "ping -c 2 10.0.3.10" \
    "curl http://10.0.3.10:8000/employees" \
    "ssh erostova@10.0.2.10" \
    > /home/devops-remote/.bash_history

# Note file with internal system map (key intelligence for students)
RUN printf '%s\n' \
    "# Bastion Gateway Notes — devops-remote" \
    "# Maintained by tahmed (DevOps Lead)" \
    "" \
    "Frequently accessed internal hosts:" \
    "  Dev Workstation:  10.0.4.20  (ssh tahmed@10.0.4.20)" \
    "  HR Workstation:   10.0.4.10  (ssh sjenkins@10.0.4.10)" \
    "  Domain Controller: 10.0.2.10 (dc01.nexus.internal)" \
    "  Data Center ERP:   10.0.3.10 (http://10.0.3.10:8000)" \
    "  Production DB:     10.0.3.20 (psql -h 10.0.3.20 ...)" \
    "  SAN Storage:       10.0.3.30 (http://10.0.3.30:9000)" \
    > /home/devops-remote/INTERNAL_HOSTS.txt

USER root
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
