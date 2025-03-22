#include "pipex.h"

void	free_pipex(t_pipex *pipex)
{
	int	i;

	i = 0;
	if (!pipex || !pipex->cmds)
		return ;
	while (pipex->cmds[i])
	{
		ft_safe_free((void **)&pipex->cmds[i]->path);
		ft_safe_free((void **)&pipex->cmds[i]->origin_cmd);
		ft_free_split(pipex->cmds[i]->args);
		ft_safe_free((void **)&pipex->cmds[i]);
		i++;
	}
	ft_safe_free((void **)&pipex->cmds);
}


void	errors(int code, char *str)
{
	if (code == 1)
		ft_putendl_fd("Invalid format.\n./pipex infile \"cmd\" \"cmd\" outfile",
			2);
	if (code == 2 || code == 3)
	{
		perror(str);
		if (code == 2)
			return ;
	}
	if (code == 4)
	{
		ft_putstr_fd("Command not found: ", 2);
		if (str)
			ft_putendl_fd(str, 2);
		else
			ft_putendl_fd("(null)", 2);
	}
	if (code == 5)
		perror("Error");
}