<?php

namespace App\Controller;

use App\Entity\Todo;
use App\Repository\TodoRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Serializer\SerializerInterface;

/**
 * Class TodoController
 * @package App\Controller
 * @Route("/", name="todo_")
 */
class TodoController extends AbstractController
{

    /**
     * @Route("", name="index", methods={"GET", "POST"})
     * @param Request $request
     * @param SerializerInterface $serializer
     * @param TodoRepository $todoRepository
     * @return Response
     */
    public function index(Request $request, SerializerInterface $serializer): Response
    {
        $em = $this->getDoctrine()->getManager();

        if ($request->isMethod("POST")) {
            $values = json_decode($request->getContent(), true);
            if (!isset($values["content"])) {
                return new Response(null, Response::HTTP_BAD_REQUEST);
            }
            $todo = (new Todo())
                ->setContent($values["content"])
                ->setChecked(false);
            $em->persist($todo);
            $em->flush();
            return new JsonResponse($serializer->serialize($todo, 'json'), Response::HTTP_CREATED);
        }
        return new JsonResponse($serializer->serialize($em->getRepository(Todo::class)->findAll(), 'json'), Response::HTTP_OK);

    }

    /**
     * @Route("{id}", name="update", methods={"PUT"})
     * @param Todo $todo
     * @param Request $request
     * @param TodoRepository $todoRepository
     * @param SerializerInterface $serializer
     * @return JsonResponse
     */
    public function update(Todo $todo, Request $request, TodoRepository $todoRepository, SerializerInterface $serializer)
    {
        $todo = $todoRepository->find($todo->getId());
        $values = json_decode($request->getContent(), true);

        if (isset($values["content"])) {
            $todo->setContent($values["content"]);
        }
        if (isset($values["checked"])) {
            $todo->setChecked($values["checked"]);
        }

        $this->getDoctrine()->getManager()->flush();
        return new JsonResponse($serializer->serialize($todo, 'json'), Response::HTTP_OK);
    }

    /**
     * @Route("{id}", name="delete", methods={"DELETE"})
     * @param Todo $todo
     * @return JsonResponse
     */
    public function delete(Todo $todo)
    {
        $this->getDoctrine()->getManager()->remove($todo);
        $this->getDoctrine()->getManager()->flush();
        return new JsonResponse(null, Response::HTTP_NO_CONTENT);
    }

}

