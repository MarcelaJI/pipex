#include "pipex_bonus.h"

void	handle_here_doc(t_pipex *pipex)
{
	int		fd;
	char	*line;

	fd = open(HERE_DOC_TMP, O_CREAT | O_WRONLY | O_TRUNC, 0644);
	if (fd < 0)
	{
		errors(2, HERE_DOC_TMP);
		exit(EXIT_FAILURE);
	}
	while (1)
	{
		write(1, "here_doc> ", 10);
		line = get_next_line(STDIN_FILENO);
		if (!line)
			break ;
		if (ft_strncmp(line, pipex->limiter, ft_strlen(pipex->limiter)) == 0
			&& line[ft_strlen(pipex->limiter)] == '\n')
		{
			free(line);
			break ;
		}
		write(fd, line, ft_strlen(line));
		free(line);
	}
	close(fd);
}

