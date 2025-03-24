#include "pipex.h"

int	execute(t_cmd *cmd, char **env)
{
	if (!cmd || !cmd->path || !cmd->args)
		return (-1);  // Si el comando no existe o no está bien formado, devolvemos error
	if (access(cmd->path, X_OK) != 0)
		return (-1);  // Si no se puede ejecutar el comando
	execve(cmd->path, cmd->args, env);
	return (-1);
}


void    pipex(int ac, char **av, char **env)
{
    t_pipex pipex;
    int pid1;
    int pid2;
    int pipend[2];

    pipex.infile = av[1];
    pipex.outfile = av[ac - 1];
    pipex.number_cmds = ac - 3;
    parse_cmds(&pipex, av, env);
    if (pipe(pipend) == -1)
        (errors(5, NULL), free_pipex(&pipex), exit(3));
    pid1 = fork();
    if (pid1 < 0)
        (free_pipex(&pipex), exit(EXIT_FAILURE));
    if (pid1 == 0)
        child1(&pipex, env, pipend);
    close(pipend[1]);
    pid2 = fork();
    if (pid2 < 0)
        (free_pipex(&pipex), exit(EXIT_FAILURE));
    if (pid2 == 0)
        child2(&pipex, env, pipend);
    close(pipend[0]);
    wait_childs(pid1, pid2, &pipex);
}


int main(int argc, char **argv, char **env)
{
    if(!*env || !env)       
    {
        ft_putendl_fd("No enviroment found.", 2);
        exit(2);
    }
    if (argc != 5)
        errors(1, NULL);
    pipex(argc, argv, env);
}