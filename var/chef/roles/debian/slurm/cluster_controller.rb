name 'cluster_controller'
description 'Slurm Cluster Controller'
run_list(
  'recipe[sys::apt]',
  'recipe[sys::accounts]',
  'recipe[sys::directory]',
  'recipe[sys::file]'
)
default_attributes(
  sys: {
    apt: {
      packages: [
        'nfs-kernel-server',
        'slurmctld',
        'slurmdbd'
      ]
    },
    accounts: {
      spock: { 
        uid: 1111,
        home: '/network/spock',
        shell: '/bin/bash'
      },
      sulu: { 
        uid: 1112,
        home: '/network/sulu',
        shell: '/bin/bash'
      },
      kirk: { 
        uid: 1113,
        home: '/network/kirk',
        shell: '/bin/bash'
      },
      uhura: { 
        uid: 1114,
        home: '/network/uhura',
        shell: '/bin/bash'
      }
    },
    #
    # Create use directories on the shared storage
    #
    directory: {
      '/network' => {},
      '/network/spock' => { owner: 'spock' },
      '/network/sulu' => { owner: 'sulu' },
      '/network/kirk' => { owner: 'kirk' },
      '/network/uhura' => { owner: 'uhura' }
    },
    file: {
      # 
      # The Slurm configuration directory as well as a shared storage /network
      # are exported to be mounted bu the execution nodes
      #
      '/etc/exports' => { 
        content: "/etc/slurm-llnl lx*(ro,sync,no_subtree_check)\n/network lx*(rw)\n"
      },
      '/etc/munge/munge.key' => {
        content: '030340d651edb16efabf24a8c080d4b7',
      }
    }
  } 
)

