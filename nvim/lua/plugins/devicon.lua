return {
   'kyazdani42/nvim-web-devicons',
   config = function()
      require 'nvim-web-devicons'.setup {
         override = {
            ['nodemon.json'] = {
               icon  = '',
               color = '#428850',
               name  = 'Nodemon'
            },
            ['Makefile'] = {
               icon  = '',
               color = '#428850',
               name  = 'Makefile'
            },
            ['.node-version'] = {
               icon  = '',
               color = '#a85813',
               name  = 'NodeVersion'
            },
            ['docker-compose.yml'] = {
               icon  = '',
               color = '#a85813',
               name  = 'DockerCompose'
            },
            ['gitlab-ci.yml'] = {
               icon  = '',
               color = '#a85813',
               name  = 'GitLabCi'
            },
            ['.dockerignore'] = {
               icon  = '',
               color = '#515151',
               name  = 'DockerIgnore'
            },
            ['Dockerfile'] = {
               icon  = '',
               color = '#0e67cc',
               name  = 'DockerFile'
            },
            ['go.mod'] = {
               icon  = '',
               color = '#0e67cc',
               name  = 'GoMod'
            },
            zsh = {
               icon  = '',
               color = '#428850',
               name  = 'Zsh'
            },
            http = {
               icon  = '黎',
               color = '#571275',
               name  = 'Http'
            },
            ['env.sample'] = {
               icon  = '',
               color = '#428850',
               name  = 'Env'
            },
            ['.env.sample'] = {
               icon  = '',
               color = '#428850',
               name  = 'Env1'
            },
            ['.env'] = {
               icon  = '',
               color = '#428850',
               name  = 'Env2'
            },
            ['.env.local'] = {
               icon  = '',
               color = '#428850',
               name  = 'Env3'
            },
            ['package.json'] = {
               icon  = '',
               color = '#a85813',
               name  = 'PackageJson'
            },
            ['package-lock.json'] = {
               icon  = '',
               color = '#a85813',
               name  = 'PackageLockJson'
            },
            ['yarn.lock'] = {
               icon  = '',
               color = '#a85813',
               name  = 'YarnLock'
            },
            ['pnpm-lock.yaml'] = {
               icon  = '',
               color = '#a85813',
               name  = 'PnpmLock'
            },
            ['tsconfig.tsbuildinfo'] = {
               icon  = '',
               color = '#0e67cc',
               name  = 'TsconfBuild'
            },
            ['tsconfig.json'] = {
               icon  = '',
               color = '#0e67cc',
               name  = 'Tsconf'
            },
            ['.editorconfig'] = {
               icon  = '',
               color = '#0e67cc',
               name  = 'Ediconf'
            },
            ['.eslintrc.json'] = {
               icon  = '',
               color = '#0e67cc',
               name  = 'Eslint'
            },
            ['.eslintrc.yml'] = {
               icon  = '',
               color = '#0e67cc',
               name  = 'Eslint1'
            },
            ['.eslintrc.cjs'] = {
               icon  = '',
               color = '#0e67cc',
               name  = 'Eslint2'
            },
            ['.eslintrc.js'] = {
               icon  = '',
               color = '#0e67cc',
               name  = 'Eslint3'
            },
            ['.prettierignore'] = {
               icon  = '',
               color = '#0e67cc',
               name  = 'PrettyIgnore'
            },
            ['.prettierrc'] = {
               icon  = '',
               color = '#0e67cc',
               name  = 'Pretty'
            },
            ['readme.md'] = {
               icon  = '',
               color = '#11bfb7',
               name  = 'Readme'
            },
            ['README.md'] = {
               icon  = '',
               color = '#11bfb7',
               name  = 'Readme1'
            },
            ['index.js'] = {
               icon  = '',
               color = '#11bfb7',
               name  = 'Index'
            },
            ['index.ts'] = {
               icon  = '',
               color = '#11bfb7',
               name  = 'Index1'
            },
            ['main.js'] = {
               icon  = '',
               color = '#11bfb7',
               name  = 'MainJs'
            },
            ['main.ts'] = {
               icon  = '',
               color = '#11bfb7',
               name  = 'MainTs'
            },
            ['app.js'] = {
               icon  = '',
               color = '#11bfb7',
               name  = 'AppJs'
            },
            ['app.ts'] = {
               icon  = '',
               color = '#11bfb7',
               name  = 'AppTs'
            },
            prisma = {
               icon  = '',
               color = '#571275',
               name  = 'Prisma'
            },
            ['nest-cli.json'] = {
               icon  = '',
               color = '#Ff005d',
               name  = 'NestCli'
            },
         },
         default  = true,
      }
   end
}
