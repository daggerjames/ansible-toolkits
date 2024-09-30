# requirements

use `ansible-playbook`

## install ansible

```
# 装ansible
# https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pipx
pipx install --include-deps ansible

# 装ansible插件
ansible-galaxy collection install -r requirements.yml
```

## basic run

### 初始化所有机器
```
# set up hosts file
# cp hosts.example hosts 
# modify it as required

ansible-playbook -i hosts preinstall.yml
```

### 部署第三方依赖

### Doris 相关
```
# 修改需要规划的配置文件，包括
# hosts 里面和 doris 相关的
# cp doris/conf/cluster.example.yml doris/conf/cluster.yml
# 如果对doris的一些定义的配置需要改动，如端口等，参考 
# doris/conf/setup_vars.yml
# doris/conf/be_conf/be.conf
# doris/conf/fe_conf/fe.conf

# 如果未曾构建，初始构建执行
ansible-playbook -i hosts doris/doris_build.yml
该构建会在当前机器运行

# 上述配置设置好后，初始化机器
ansible-playbook -i hosts doris/check_env.yml

# 首次部署
ansible-playbook -i hosts doris/setup.yml
```
